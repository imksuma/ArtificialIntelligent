% This is an example script to segment an ellipse from image.
% The ellipse in image is constructed by some dots.
% this script using optimization algorithm to detect most likely ellipse region.
% the fitness is formulated as summation of those dots.
% this scripst using cuckoo search as main optimization algorithm.
% if you find this script is helpful to you, please cite the original paper of cuckoo search
% Yang and S. Deb, “Cuckoo search via lévy flights,” in Nature & Biologically Inspired Computing, 2009. NaBIC 2009. World Congress on. IEEE, 2009, pp. 210–214
% and please cite my paper too I. Kusuma, M. A. Ma'sum, H. S. Sanabila, H. A. Wisesa, W. Jatmiko, A. M. Arymurthy and B. Wiweko, "Fetal Head Segmentation Based On Gaussian Elliptical Path Optimize By Flower Pollination Algorithm And Cuckoo Search," 2016 International Conference on Advanced Computer Science and Information Systems (ICACSIS), Depok, 2016.
% author : ilham kusuma
function [result] = EllipseSegmentationCuckoo()

FilenamesCell=dir('*.JPG');

beta=3/2;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);

ToDo=1:numel(FilenamesCell);   % index of the images in FilenamesCell that we want to process
for ii=ToDo
    fnamme = FilenamesCell(ii).name; 
    disp(['work : ', fnamme]);
    img = imread( FilenamesCell(ii).name); % read image

    ListPixel = [];

    img(img<50)=0;
    img(img>=50)=1;
    for yy=1:size(img,1)
        for xx=1:size(img,2)
            if img(yy,xx)
                ListPixel=[ListPixel; yy,xx];
            end
        end
    end
    
    numPixel = size(ListPixel,1);
    koor=[];
    minFitKoor=0;
    for n=1:numPixel*10
        perm = randperm(numPixel);
        fit=fitLine(ListPixel,[ListPixel(perm(1),:),ListPixel(perm(2),:)]);
        if fit<minFitKoor
            minFitKoor=fit;
            koor=[ListPixel(perm(1),:),ListPixel(perm(2),:)];
            disp(['fit : ', num2str(fit), ', koor : ', num2str(koor)]);
        end
    end

    [newKoor, length, theta]= findKoor(ListPixel,koor);
    
    r=length/2;
    
    aaMin= min(newKoor(1),newKoor(3));
    aaMax= max(newKoor(1),newKoor(3));
    
    if aaMax-aaMin<40
        aaMin=aaMin-30;
        aaMax=aaMax+30;
    end
    
    bbMin= min(newKoor(2),newKoor(4));
    bbMax= max(newKoor(2),newKoor(4));

    if bbMax-bbMin<40
        bbMin=bbMin-30;
        bbMax=bbMax+30;
    end

    Lb=[aaMin bbMin r*0.9 r*0.9 (theta)-pi/16];
    Ub=[aaMax bbMax r*1.2 180   (theta)+pi/16];
    
    nPop=25;
    d=size(Lb,2);
    
    N_iter=1000;
	
	listOfEllipse=zeros(3,size(Lb,2));
	listOfFitEllipse=zeros(3,1);
	for ii=1:size(listOfEllipse,1)
		fitness=zeros(1,d);
			
		Sol=zeros(nPop,d);
		S=Sol;
		
		pa=0.25;
		
		for n=1:nPop
			Sol(n,:)=Lb+(Ub-Lb).*rand(1,d);
			fitness(n)=fitEllipse(ListPixel,Sol(n,:));
		end
		
		[fmin, k] = min(fitness);
		best=Sol(k,:);

		iter = 1;
		while iter < N_iter & sum(min(Sol)==max(Sol))~=d-1        
			for n=1:size(Sol,1)
				if mod(iter,2)==1
					JK=randperm(size(Sol,1));                    
					K=rand(1,d)>pa;
					S(n,:)=Sol(n,:)+K.*rand.*(Sol(JK(1),:)-Sol(JK(2),:));
				else
					u=randn(1,d)*sigma;
					v=randn(1,d);
					step=u./abs(v).^(1/beta);
					stepsize=0.01*step.*(Sol(n,:)-best);
					S(n,:)=S(n,:)+0.01*step.*(Sol(n,:)-best).*randn(size(Lb));
				end

				tempS=S(n,:);
				tempS(S(n,:)<Lb)=Lb(S(n,:)<Lb);
				tempS(S(n,:)>Ub)=Ub(S(n,:)>Ub);
				S(n,:)=tempS;

				S(n,1:4)=floor(S(n,1:4));

				Fnew=fitEllipse(ListPixel,S(n,:));
				% If fitness improves (better solutions found), update then
				if Fnew<fitness(n)
					Sol(n,:)=S(n,:);
					fitness(n)=Fnew;
				end

				% Update the current global best
				if Fnew<fmin,
					best=S(n,:);
					fmin=Fnew;
				end
			end
			% Display results every 100 iterations
			if round(iter/500)==iter/500,
				disp(['fitEllipse : ', num2str(fmin), ', best : ', num2str(best)]);
				disp(['min : ', num2str(min(Sol))]);
				disp(['max : ', num2str(max(Sol))]);
			end
			
			iter = iter+1;
		end
		disp(['fitEllipse : ', num2str(fmin), ', best : ', num2str(best)]);
		listOfEllipse(ii,:)=best;
		listOfFitEllipse(ii)=fmin;
	end
	[minFit idxBest]=min(listOfFitEllipse);
    best=listOfEllipse(idxBest,:);
    imgEllipse=drawEllipse(best);
    imwrite(xor(img,imgEllipse),[fnamme(1:end-4), '-fit.JPG']);
	result=imgEllipse;
end

function [fit] = fitLine(ListPixel, param)

	ca2=param(2); cb2=param(1); %% aa = xx, bb = yy	
	ca1=param(4); cb1=param(3); 
	
	tebal = 0.1;

	if(abs(cb2-cb1)>abs(ca2-ca1))
		f=@(bb,aa) floor((bb-cb1)*((ca2-ca1)/(cb2-cb1)) + ca1 -tebal) <= (aa) & floor((bb-cb1)*((ca2-ca1)/(cb2-cb1)) + ca1 +tebal) >= (aa);
	else
		f=@(bb,aa) floor((aa-ca1)*((cb2-cb1)/(ca2-ca1)) + cb1 -tebal) <= (bb) & floor((aa-ca1)*((cb2-cb1)/(ca2-ca1)) + cb1 +tebal) >= (bb);
    end

    fit=-sum(f(ListPixel(:,1),ListPixel(:,2)));
    

function [newKoor, length, theta] = findKoor(ListPixel, param)

	ca2=param(2); cb2=param(1); %% aa = xx, bb = yy	
	ca1=param(4); cb1=param(3); 
	
	tebal = 0;

	if(abs(cb2-cb1)>abs(ca2-ca1))
		f=@(bb,aa) floor((bb-cb1)*((ca2-ca1)/(cb2-cb1)) + ca1 -tebal) <= (aa) & floor((bb-cb1)*((ca2-ca1)/(cb2-cb1)) + ca1 +tebal) >= (aa);
        listBenar = f(ListPixel(:,1),ListPixel(:,2));
        B=ListPixel(listBenar,1);
        [vMin, kMin] = min(B);
        [vMax, kMax] = max(B);
        B=ListPixel(listBenar,:);
        
        newKoor=[B(kMin,:), B(kMax,:)];
	else
		f=@(bb,aa) floor((aa-ca1)*((cb2-cb1)/(ca2-ca1)) + cb1 -tebal) <= (bb) & floor((aa-ca1)*((cb2-cb1)/(ca2-ca1)) + cb1 +tebal) >= (bb);
        listBenar = f(ListPixel(:,1),ListPixel(:,2));
        B=ListPixel(listBenar,2);
        [vMin, kMin] = min(B);
        [vMax, kMax] = max(B);
        B=ListPixel(listBenar,:);
        
        newKoor=[B(kMin,:), B(kMax,:)];
    end
    
    length=sqrt((newKoor(1)-newKoor(3))^2 + (newKoor(2)-newKoor(4))^2);
%    theta=atan((max(newKoor(3),(newKoor(1)))-min(newKoor(3),(newKoor(1))))/((newKoor(2)-newKoor(4))));
    theta=atan((newKoor(3)-newKoor(1))/((newKoor(2)-newKoor(4))));
function [fit] = fitEllipse(ListPixel, param)

    cx1=param(1); cy1=param(2); m=param(3);m2=param(4);%m pendek

    s=tan(param(5));
    f=@(xx,yy) (((yy-cy1)-s*(xx-cx1)).^2/(m^2*(1+s^2)) + (s*(yy-cy1)+(xx-cx1)).^2/ (m2^2*(1+s^2))) <= 1 & (((yy-cy1)-s*(xx-cx1)).^2/(m^2*(1+s^2)) + (s*(yy-cy1)+(xx-cx1)).^2/ (m2^2*(1+s^2))) >= 0.96;

    fit=-sum(f(ListPixel(:,1),ListPixel(:,2)));    

function [img] = drawEllipse(param)

    cx1=param(1); cy1=param(2); m=param(3);m2=param(4);%m pendek

    s=tan(param(5));
    f=@(xx,yy) (((yy-cy1)-s*(xx-cx1)).^2/(m^2*(1+s^2)) + (s*(yy-cy1)+(xx-cx1)).^2/ (m2^2*(1+s^2))) <= 1 & (((yy-cy1)-s*(xx-cx1)).^2/(m^2*(1+s^2)) + (s*(yy-cy1)+(xx-cx1)).^2/ (m2^2*(1+s^2))) >= 0.96;

    cc=1:400;
	rr=(1:600)';

    img=bsxfun(f,rr,cc); %Logical map of 2 circles
