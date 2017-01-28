library(datasets)
#fit <- lm(Volume ~ Girth + Height, method="qr", data=trees)
#summary(fit)

nrow.trees<-nrow(trees)
ncol.trees<-ncol(trees)

arr.test<-c(.3,.4,.5,.6,.7,.8,.9)
arr.mr<-c()
for (ii in arr.test){
	n.part<-ii
	arr.mean<-1:100
	for(jj in arr.mean){
		arr.sampling<-sample(1:nrow.trees)
		trees.train<-trees[arr.sampling[1:floor(nrow.trees*n.part)],]
		trees.test<-trees[arr.sampling[ceiling(nrow.trees*n.part):nrow.trees],]

		fit<-lm(Volume ~ Girth+Height, data=trees.train)
#		summary(fit)

		arr.diff <- trees.train[,3]-predict(fit, trees.test)
		for(ii in 1:length(arr.diff)){arr.diff[ii]<-arr.diff[ii]^2}
		arr.mean[jj]<-mean(arr.diff)
	}
	arr.mr[length(arr.mr)+1]<-mean(arr.mean)
	
}
print(arr.mr)

fit<-lm(Volume ~ Height + Girth, data=trees)

arr.diff <- trees[,3]-predict(fit, trees)
for(ii in 1:length(arr.diff)){arr.diff[ii]<-arr.diff[ii]^2}
mean(arr.diff)
