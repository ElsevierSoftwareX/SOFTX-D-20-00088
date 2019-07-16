% BSD 3-Clause License
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
% 
% * Neither the name of Aalto University nor the names of its
%   contributors may be used to endorse or promote products derived from
%   this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Use this instead of collapse-function under wit-class if you want direct
% READ+WRITE access to Name-Value pairs of each tag. This is particularly
% useful for quick modifications of small wit-formatted files. For larger
% files, use struct-based collapse-function under wit-class instead.
classdef wit_debug < dynamicprops, % Since R2008a
    methods
        % Use this constructor for reverse engineering to achieve interoperability.
        function obj = wit_debug(O_wit),
            if nargin > 0,
                obj.collapse(O_wit);
            end
        end
        
        % This uses different property-naming than collapse-function under
        % wit-class because of automatic property sorting feature. Anyhow
        % the output is more compacto for this class due to lack of Tags.
        function collapse(obj, O_wit, Pre),
            if nargin < 3, Pre = 'Tree_'; end
            for ii = 1:numel(O_wit),
                Id = sprintf(sprintf('%%0%dd', floor(log10(numel(O_wit))+1)), ii);
                prop_name = addprop(obj, [Pre Id '_Name']);
                prop_name.GetMethod = @(x) get_Name(x, O_wit(ii));
                prop_name.SetMethod = @(x, y) set_Name(x, y, O_wit(ii));
                if isa(O_wit(ii).Data, 'wit'),
                    obj.collapse(O_wit(ii).Data, [Pre Id '_Value_']);
                else,
                    prop_data = addprop(obj, [Pre Id '_Value']);
                    prop_data.GetMethod = @(x) get_Data(x, O_wit(ii));
                    prop_data.SetMethod = @(x, y) set_Data(x, y, O_wit(ii));
                end
            end
        end
        
        function Name = get_Name(~, Tag),
            Name = Tag.Name;
        end
        
        function set_Name(~, Name, Tag),
            Tag.Name = Name;
        end
        
        function Data = get_Data(~, Tag),
            Data = Tag.Data;
        end
        
        function set_Data(~, Data, Tag),
            Tag.Data = Data;
        end
    end
end
