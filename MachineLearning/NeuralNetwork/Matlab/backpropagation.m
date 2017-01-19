% example
% [Network, prediction] = backpropagationSBGD([1 1; 1 -1; -1 1; -1 -1], [-1 1; 1 -1; 1 -1; -1 1], 1000, 0.05, 0.0004, [2 2 2])
% [Network, prediction] = backpropagationSBGD([1 1; 1 -1; -1 1; -1 -1], [-1; 1; 1; -1], 1000, 0.05, 0.0004, [2 2 2])
% [Network, prediction] = backpropagationSBGD([1;0.9;0.8;0.7;0.6;0.5;0.4;0.3;0.2;0.1; 0;-0.1;-0.2;0.-0.3;-0.4;-0.5;-0.6;-0.7;-0.8;-0.9;-1], [1; 1; 1; 1;-1; 1; 1;-1;-1;-1;-1; -1; -1;  -1;  1;  1; -1;  1;  1;  1; 1], 1000, 0.05, 0.0004, [1 9 1])
function [Network, prediction] = backpropagation(input, output, iteration, alpha, tol, Layer)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Backpropagation 1 vs all, using sigmoid bipolar activation function
	% based on gradient descent for minimize the error 
	% pull 2
	% author : ilham Kusuma
	%
	% input : matrix P x M, P is number of sample
	%		  M is the features
	% output : matrix Pd x Md, Pd = P is number of sample
	%		   Md is number of class. digunakan untuk training
	% iteration : epoch
	% alpha : learning rate.
	% tol : error tolerance
	% Layer : matrix 1 x Ml, Ml is number of layer. the value is 
	% 		  represented number of node. 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	[numberDataSet nFeature] = size(input);
	[numberDataSet nLabel] = size(output);

	nLayer = length(Layer(1,:)); % banyaknya layer


    if nLabel == Layer(1,end) & nLayer >= 3 & nFeature == Layer(1,1) % checking the desired structure network  
	
    	% weight initialization(random)
        b = -0.4; % negative range 
        a = -b; % positive range  

        A(2).weight =  a + (b-a).*rand(Layer(1,2),nFeature);
		A(2).bias = a + (b-a).*rand(Layer(1,2),1);

		for i = 3:nLayer
			A(i).weight =  a + (b-a).*rand(Layer(1,i),Layer(1,i-1));
			A(i).bias = a + (b-a).*rand(Layer(1,i),1);
		end
		indeks = 1;
		error = 1;

        while iteration > 0 & error > tol 
			A(end).deltaNode = zeros(Layer(1,end),1);
			
            for i = 1:numberDataSet; 
				% feedforward
				A(1).nodeAF = input(i,:)';				
				for j = 2:nLayer;
					A(j).node = A(j).bias + A(j).weight * (A(j-1).nodeAF* 1.0);
					A(j).nodeAF = 2./(1+exp(-A(j).node)) - 1;
                end
				vektorError = output(i,:)' - A(end).nodeAF; % compute the difference of network output and target
                error = sum((vektorError'*vektorError))/nLabel;
				% Backpropagation of error
				% delta calculation
				
				A(end).deltaNode = vektorError .* (0.5  .* (1+A(end).nodeAF) .* (1-A(end).nodeAF));
				A(end).deltWeigth = (alpha * A(end).deltaNode * (A(end-1).nodeAF')); % 
				A(end).deltaBias = alpha*A(end).deltaNode; 

                for j = nLayer - 1:-1:2 % each hidden layer
					A(j).deltaNode = (A(j+1).weight' * A(j+1).deltaNode) .* 0.5 .* (1+A(j).nodeAF) .* (1-A(j).nodeAF);
					A(j).deltWeigth = (alpha * A(j).deltaNode * (A(j-1).nodeAF')); 
					A(j).deltaBias = alpha*A(j).deltaNode;
                end

				% update weight
                for j = 2:nLayer;
					A(j).weight = A(j).weight + A(j).deltWeigth;
					A(j).bias = A(j).bias + A(j).deltaBias;
                end
            end
            			
			iteration = iteration - 1;
        end
		
        prediction=zeros(size(output));
        for i = 1:numberDataSet; 
            % feedforward
            A(1).nodeAF = input(i,:)';				
            for j = 2:nLayer;
                A(j).node = A(j).bias + A(j).weight * (A(j-1).nodeAF* 1.0);
                A(j).nodeAF = 2./(1+exp(-A(j).node)) - 1;
            end
            prediction(i,:) = A(end).nodeAF; % compute the difference of network output and target
        end
%         Network=1:nLayer;
		%% output network
		for i = 2:nLayer;
			Network(i).weight = A(i).weight;		
			Network(i).bias = A(i).bias;
		end
		
		%save networkbackpropagationmodul Network
%		dlmwrite(['backpropagation-progresError-result.csv'],progresError');
	else
		error = 1;
	end
end 
