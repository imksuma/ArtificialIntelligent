clc;close all;clear all;

path = 'E';
numDat = 1;
vid = 0;
vid2 = 0;

ff = 0;
ff2 = 0;
ff3 = 0;
nFiltSize=8;
nFiltRadius=1;
filtR=generateRadialFilterLBP(nFiltSize, nFiltRadius);
A(1).featureLBP = [];
A(2).featureLBP = [];
A(3).featureLBP = [];
A(4).featureLBP = [];
A(5).featureLBP = [];
A(6).featureLBP = [];
A(7).featureLBP = [];
A(8).featureLBP = [];
binsRange=(1:2^nFiltSize)-1;

while vid <= 0
	while vid2 <= 1
		find = 2;
		kelas=1;
		while kelas<=8
			while ff < 4 
				while ff2 <= 9 
					while ff3 <= 9  % iterasi
						filePath = [path num2str(vid) num2str(vid2) '/' num2str(kelas) '/Frame' num2str(ff) num2str(ff2) num2str(ff3) '.png'];
						find = exist(filePath);
						if find == 2 % jika ada
							disp(filePath);
							I = imread(filePath);

							I2 = double(I);
							Ivessel=FrangiFilter2D(I2);
					
							GLCM2 = graycomatrix(Ivessel,'Offset',[2 0;0 2]);
							stats = GLCM_Features1(GLCM2,0);
							feature = [stats.autoc, stats.contr, stats.corrm, stats.corrp, stats.cprom, stats.cshad, stats.dissi, stats.energ, stats.entro, stats.homom, stats.maxpr, stats.sosvh, stats.savgh, stats.svarh, stats.senth, stats.dvarh, stats.denth, stats.inf1h, stats.inf2h, stats.indnc, stats.idmnc];

							A(kelas).featureLBP = [A(kelas).featureLBP; feature];

							end
						ff3=ff3+1;
					end
					ff3 = 0;
					ff2 = ff2+1;
				end
				ff2=0;
				ff=ff+1;
			end
			ff=0;
			kelas=kelas+1;
		end
		kelas=1;		
		vid2 = vid2+1;
	end
	vid2=0;
	vid = vid+1;
end
vid=0;

%state='menyiapkan input dan output'
input = (A(1).featureLBP);
input = [input; (A(2).featureLBP)];
input = [input; (A(3).featureLBP)];
input = [input; (A(4).featureLBP)];
input = [input; (A(5).featureLBP)];
input = [input; (A(6).featureLBP)];
input = [input; (A(7).featureLBP)];
input = [input; (A(8).featureLBP)];

targets = [];
targets = [targets; repmat(1, size(A(1).featureLBP,1), 1)];
targets = [targets; repmat(2, size(A(2).featureLBP,1), 1)];
targets = [targets; repmat(3, size(A(3).featureLBP,1), 1)];
targets = [targets; repmat(4, size(A(4).featureLBP,1), 1)];
targets = [targets; repmat(5, size(A(5).featureLBP,1), 1)];
targets = [targets; repmat(6, size(A(6).featureLBP,1), 1)];
targets = [targets; repmat(7, size(A(7).featureLBP,1), 1)];
targets = [targets; repmat(8, size(A(8).featureLBP,1), 1)];

sumAkurasi = 0;
sumAkurasi2 = 0;
species = cellstr(num2str(targets));

meas = input;
CVO = cvpartition(species,'k',2); % split data set, train 50% test 50%

% 2 times repetition
for j=1:2
	trIdx = CVO.training(j);
	teIdx = CVO.test(j);

	inputdata = meas(trIdx,:);
	outputdata = species(trIdx,:);%targetAngka(trIdx,:);

	inputval = meas(teIdx,:);
	outputval = species(teIdx,:);%targetAngka(teIdx,:);

	nFitur = size(inputdata,2);
	nClass = size(targets,2);
	Layer = [nFitur nFitur*nClass nFitur*nClass nClass];

	BaggedEnsemble = TreeBagger(100,inputdata,outputdata,'OOBPred','On');

%	oobErrorBaggedEnsemble = oobError(BaggedEnsemble);
%	plot(oobErrorBaggedEnsemble)
%	xlabel 'Number of grown trees';
%	ylabel 'Out-of-bag classification error';

%	oobErrorBaggedEnsemble = progresError;
%	plot(oobErrorBaggedEnsemble)
%	xlabel 'Number of epoch';
%	ylabel 'SSE';
	cariBE = BaggedEnsemble.predict(inputdata);

	conMat = confusionmat(outputdata, cariBE);
	prediksiBenar = 0;
	for j=1:8
		prediksiBenar = prediksiBenar + conMat(j,j);
	end

	akurasiTrain = prediksiBenar/size(outputval,1);
	sumAkurasi2=sumAkurasi2+akurasiTrain;
	
	cariBE = BaggedEnsemble.predict(inputval);

	conMat = confusionmat(outputval, cariBE);
	prediksiBenar = 0;
	for j=1:8
		prediksiBenar = prediksiBenar + conMat(j,j);
	end

	akurasiTest = prediksiBenar/size(outputval,1);
	sumAkurasi=sumAkurasi+akurasiTest;
end
disp(['acc train : ' num2str(sumAkurasi2/2)]);
disp(['acc test : ' num2str(sumAkurasi/2)]);
