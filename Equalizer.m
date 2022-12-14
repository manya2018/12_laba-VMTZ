classdef Equalizer < handle
properties (Constant)
    freqArray = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000,16000];
end
properties (SetAccess = private,GetAccess = public)
    order = 64;
    fs = 44100;
end
properties(Access = public)
    gane (10,1) {double}=ones(10,1);
end
properties (Access = protected)
    bBank {double}
    initB {double} = []
end
methods
    function obj=Equalizer(order,fs) 
        obj.order = order;
        obj.fs=fs;
        obj.bBank = CreateFilters(obj);
    end
    function bBank = CreateFilters(obj)
        freqArrayNorm = obj.freqArray/(obj.fs/2);
        for k=1:length(obj.freqArray)
                if k==1
                    mLow = [1, 1, 0, 0];
                    freqLow = [0, freqArrayNorm(1), 2*freqArrayNorm(1), 1];
                    bLow = fir2(obj.order, freqLow, mLow);
                elseif k==length(obj.freqArray)
                    mHigh = [0, 0, 1, 1];
                    freqHigh = [0, freqArrayNorm(end)/2, freqArrayNorm(end),1];
                    bBank(k,:) = fir2(obj.order, freqHigh, mHigh);
                else
                    mBand = [0, 0, 1, 0, 0];
                    freqBand = [0, freqArrayNorm(k-1), freqArrayNorm(k),freqArrayNorm(k+1), 1];
                    bBank(k,:) = fir2(obj.order, freqBand, mBand);
                end 
        end
    end
    function  [signalOut]=Filtering(obj,signal)
        A=obj.gane.*obj.bBank;
        B=sum(A, 2);
        [signalOut]= filter(B, 1, signal, obj.initB);
    end
    function [H, w]=GetFreqResponce(obj)
        b = sum(obj.gane.*obj.bBank);
        [H, w] = freqz(b, 1, obj.order);
    end
end
end
 