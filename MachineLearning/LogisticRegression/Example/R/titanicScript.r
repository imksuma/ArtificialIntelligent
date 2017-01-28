library(gdata)
titanic <- read.csv("E:/Test Masuk/Bukalapak/Test Tahap 1/titanic.csv")
fit <- glm(Survived ~ Class + Age + Sex, data=titanic, family = "binomial")
summary(fit)

nrow.titanic<-nrow(titanic)
ncol.titanic<-ncol(titanic)

n.part<-0.7
# using partition
arr.sampling<-sample(1:nrow.titanic)
titanic.train<-titanic[arr.sampling[1:floor(nrow.titanic*n.part)],]
titanic.test<-titanic[arr.sampling[ceiling(nrow.titanic*n.part):nrow.titanic],]

fit<-glm(Survived ~ Class + Age + Sex, data=titanic.train)
#		summary(fit)
titanic.test.predict<-predict(fit, titanic.test)

ttp<-c()
for(ii in titanic.test.predict){
	if(ii<0.5){
		ttp[length(ttp)+1]<- 0
	} else {
		ttp[length(ttp)+1]<- 1	
	}
}

tab <- table(titanic.test$Survived,ttp)

# without partition
fit<-glm(Survived ~ Class + Age + Sex, data=titanic)
#		summary(fit)
titanic.test.predict<-predict(fit, titanic)

ttp<-c()
for(ii in titanic.test.predict){
	if(ii<0.5){
		ttp[length(ttp)+1]<- 0
	} else {
		ttp[length(ttp)+1]<- 1	
	}
}

tab <- table(titanic$Survived,ttp)