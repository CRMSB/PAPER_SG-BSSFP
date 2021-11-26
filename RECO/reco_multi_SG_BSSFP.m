function struct_out = reco_multi_SG_BSSFP(s_in)
if ~strcmp(class(s_in),"OBJ_SG_BSSFP_RECO")
    error("Input is not a OBJ_SG_BSSFP_RECO class object : Defined it using -> s_in = OBJ_SG_BSSFP_RECO");
end


for i = 1:length(s_in.BRUKER_PATH)
    disp(['Perform reconstruction of datasets n°' num2str(i)]);
    %% read data
    s_out=e_SGTFisp(s_in.BRUKER_PATH{i});
    
    %% Detects peaks
    if(length(size(s_out.Nav))==2)
        y=abs(sum(double(s_out.Nav(1:s_in.SGNPoints,:)),1)); % When only 1 channel
    else
        y=abs(sum(double(s_out.Nav(1:s_in.SGNPoints,:,s_in.NavCh)),1)); %Number of points used for SG signal
    end
    y=1./y;
    
    % Filtre gaussien appliquée aux données
    x = linspace(-s_in.sizef / 2-1, s_in.sizef / 2, s_in.sizef);
    gaussFilter = exp(-x .^ 2 / (2 * s_in.sigma ^ 2));
    gaussFilter = gaussFilter / sum (gaussFilter); % normalize
    
    yfilt = conv (y, gaussFilter,'same');
    
    T = s_out.bruk.method.PVM_RepetitionTime/1000;                     % Sample time
    Fs = 1/T;                    % Sampling frequency
    L = length(y);                     % Length of signal
    t = (0:L-1)*T;                % Time vector
    
    
    idxECG=peakfinder(yfilt/max(yfilt),s_in.NavThreshold);
    
    if (i==1 && s_in.showFigure==1)
        figure;plot(t,y);hold on;
        plot(t,yfilt,'r');
        plot(t(idxECG),yfilt(idxECG),'or');
        title('Signal');
        xlabel('time (seconds)');
        
        dlgTitle    = 'User Question';
        dlgQuestion = 'Check Pick detection. Do you wish to continue ? ';
        
        choice=MFquestdlg([0.4,0.5],dlgQuestion,dlgTitle,'Yes','No','Yes');
        
        if(strcmp(choice,'No'))
            error('Select New parameters for : sigma,sizef,SGNPoints,NavCh');
        end
    end
    
    %% Remove motion corrupted lines
    
    idxECG(1)=[];
    %idxECG(1)=[];
    idxECG(end)=[];
    
    idxLinePos=idxECG+s_in.RespWindowPos;
    idxLineNeg=idxECG-s_in.RespWindowNeg;
    
    idxWindow=[];
    for j=1:length(idxLineNeg)
        idxWindow=[idxWindow idxLineNeg(j):idxLinePos(j)];
    end
    
    
    idxLine=[idxLineNeg idxLinePos];
    idxLine(idxLine < 1)=[];
    
    if (i==1 && s_in.showFigure==1)
        figure;hax=axes;
        plot(t,y);hold on;
        plot(t,yfilt,'r');
        plot(t(idxECG),yfilt(idxECG),'or');
        title('Signal');
        xlabel('time (seconds)');
        
        line([t(idxLine)' t(idxLine)'],get(hax,'YLim'),'Color',[0 1 1])
        
        dlgTitle    = 'User Question';
        dlgQuestion = 'Check, window selection. Do you wish to continue ? ';
        
        choice=MFquestdlg([0.4,0.5],dlgQuestion,dlgTitle,'Yes','No','Yes');
        
        if(strcmp(choice,'No'))
            error('Select New parameters for : RespWindowPos,RespWindowNeg')
        end
    end
    
    %%
    kdata2=reshape(s_out.kdata,s_out.bruk.method.PVM_Matrix(1),[],s_out.bruk.method.PVM_EncNReceivers);
    
    for j=1:length(idxWindow)
        kdata2(:,idxWindow(j),:)=nan;
    end
    
    kdata2=reshape(kdata2,size(s_out.kdata));
    
    mask=kdata2;
    mask(~isnan(mask))=1;
    mask(isnan(mask))=0;
    mask=sum(mask,4); %sum along NR dimension (take care the dimension is not the same as BART)
    
    disp(['Percentage of lines with 0 : ' num2str(sum(mask(:)==0)/length(mask(:))*100)]);     % Percentage of lines with 0
    mask(mask==0)=1;
    
    kdata3=kdata2;
    kdata3(isnan(kdata3))=0;
    kdata3=sum(kdata3,4)./mask; % divide by number of lines added
    
    imCor=fftshift(ifft(ifft(ifft(fftshift(kdata3),[],1),[],2),[],3));
    struct_out.imCor{i}=sqrt(sum(abs(imCor).^2,5)); % sum of squares along channel 

end

imSOS = zeros(size(struct_out.imCor{1}));

for i = 1:length(s_in.BRUKER_PATH)
    imSOS = imSOS + struct_out.imCor{i}.^2;
end
struct_out.imSOS = sqrt(imSOS);

struct_out.s_in=s_in;
end