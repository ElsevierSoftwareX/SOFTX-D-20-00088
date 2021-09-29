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

% BSD 2-Clause License (== BSD 3-Clause License but without its 3rd clause on non-endorsement)
% Copyright (c) 2019, Devin Hussey (author of the cleaned up implementation at https://github.com/easyaspi314/xxhash-clean)
% Copyright (c) 2019, Yann Collet (author of the official version at https://github.com/Cyan4973/xxHash)
% All rights reserved.

function hash_u64 = xxh3_64(input, seed_or_secret), %#ok
    % Helper function to HASH the input data by the XXHASH hash algorithm
    % or specifically its XXH3 (64-bit) variant. It stands for extremely
    % fast non-cryptographic hash algorithm. This can be seeded or salted
    % with custom secrets. This MATLAB implementation was ported from the
    % Devin Hussey's version. The vector-optimized code performance (for an
    % input of larger than 240 bytes) is still about 4 times slower than
    % Java's md5, which is memory limited, and about 100 times slower than
    % the official version. This will process the huge input as blocks of
    % size (approximately) 64MB or less.
    %
    % INPUT:
    % input = any numeric, logical or char array.
    % seed_or_secret = any numeric, logical or char array. If not given,
    % then seed = 0 and secret = built-in default. If given, then a scalar
    % value is taken as a 64-bit seed. If given, then a vector value is
    % taken as an array of custom secrets. In the vector case, its length
    % must be >= XXH3_SECRET_SIZE_MIN.
    %
    % OUTPUT:
    % hash_u64 = An unsigned 64-bit integer hash value.
    
    
    
    %% SELF-TEST WHEN NO INPUTS AND OUTPUTS
    XXH3_SECRET_SIZE_MIN = 136;
    if nargin == 0 && nargout == 0, self_verification(); return; end
    
    
    
    %% DEFINITIONS
    PRIME32_1 = uint64(2654435761); % 0x9E3779B1U or 0b10011110001101110111100110110001
    PRIME32_2 = uint64(2246822519); % 0x85EBCA77U or 0b10000101111010111100101001110111
    PRIME32_3 = uint64(3266489917); % 0xC2B2AE3DU or 0b11000010101100101010111000111101
    PRIME64_1 = uint64(11400714785074694791); % 0x9E3779B185EBCA87ULL or 0b1001111000110111011110011011000110000101111010111100101010000111
    PRIME64_2 = uint64(14029467366897019727); % 0xC2B2AE3D27D4EB4FULL or 0b1100001010110010101011100011110100100111110101001110101101001111
    PRIME64_3 = uint64(1609587929392839161); % 0x165667B19E3779F9ULL or 0b0001011001010110011001111011000110011110001101110111100111111001
    PRIME64_4 = uint64(9650029242287828579); % 0x85EBCA77C2B2AE63ULL or 0b1000010111101011110010100111011111000010101100101010111001100011
    PRIME64_5 = uint64(2870177450012600261); % 0x27D4EB2F165667C5ULL or 0b0010011111010100111010110010111100010110010101100110011111000101
    
    % /* Pseudorandom data taken directly from FARSH */
    kSecret_u8 = uint8([184 254 108 57 35 164 75 190 124 1 129 44 247 33 173 28 ...
        222 212 109 233 131 144 151 219 114 64 164 164 183 179 103 31 ...
        203 121 230 78 204 192 229 120 130 90 208 125 204 255 114 33 ...
        184 8 70 116 247 67 36 142 224 53 144 230 129 58 38 76 ...
        60 40 82 187 145 195 0 203 136 208 101 139 27 83 46 163 ...
        113 100 72 151 162 13 249 78 56 25 239 70 169 222 172 216 ...
        168 250 118 63 227 156 52 63 249 220 187 199 199 11 79 29 ...
        138 81 224 75 205 180 89 49 200 159 126 201 217 120 115 100 ...
        234 197 172 131 52 211 235 195 197 129 160 255 250 19 99 235 ...
        23 13 221 81 183 240 218 73 211 22 85 38 41 212 104 158 ...
        43 22 190 88 125 71 161 252 143 248 184 209 122 208 49 206 ...
        69 203 58 143 149 22 4 40 175 215 251 202 187 75 64 126]);
    %     0xb8, 0xfe, 0x6c, 0x39, 0x23, 0xa4, 0x4b, 0xbe, 0x7c, 0x01, 0x81, 0x2c, 0xf7, 0x21, 0xad, 0x1c,
    %     0xde, 0xd4, 0x6d, 0xe9, 0x83, 0x90, 0x97, 0xdb, 0x72, 0x40, 0xa4, 0xa4, 0xb7, 0xb3, 0x67, 0x1f,
    %     0xcb, 0x79, 0xe6, 0x4e, 0xcc, 0xc0, 0xe5, 0x78, 0x82, 0x5a, 0xd0, 0x7d, 0xcc, 0xff, 0x72, 0x21,
    %     0xb8, 0x08, 0x46, 0x74, 0xf7, 0x43, 0x24, 0x8e, 0xe0, 0x35, 0x90, 0xe6, 0x81, 0x3a, 0x26, 0x4c,
    %     0x3c, 0x28, 0x52, 0xbb, 0x91, 0xc3, 0x00, 0xcb, 0x88, 0xd0, 0x65, 0x8b, 0x1b, 0x53, 0x2e, 0xa3,
    %     0x71, 0x64, 0x48, 0x97, 0xa2, 0x0d, 0xf9, 0x4e, 0x38, 0x19, 0xef, 0x46, 0xa9, 0xde, 0xac, 0xd8,
    %     0xa8, 0xfa, 0x76, 0x3f, 0xe3, 0x9c, 0x34, 0x3f, 0xf9, 0xdc, 0xbb, 0xc7, 0xc7, 0x0b, 0x4f, 0x1d,
    %     0x8a, 0x51, 0xe0, 0x4b, 0xcd, 0xb4, 0x59, 0x31, 0xc8, 0x9f, 0x7e, 0xc9, 0xd9, 0x78, 0x73, 0x64,
    %     0xea, 0xc5, 0xac, 0x83, 0x34, 0xd3, 0xeb, 0xc3, 0xc5, 0x81, 0xa0, 0xff, 0xfa, 0x13, 0x63, 0xeb,
    %     0x17, 0x0d, 0xdd, 0x51, 0xb7, 0xf0, 0xda, 0x49, 0xd3, 0x16, 0x55, 0x26, 0x29, 0xd4, 0x68, 0x9e,
    %     0x2b, 0x16, 0xbe, 0x58, 0x7d, 0x47, 0xa1, 0xfc, 0x8f, 0xf8, 0xb8, 0xd1, 0x7a, 0xd0, 0x31, 0xce,
    %     0x45, 0xcb, 0x3a, 0x8f, 0x95, 0x16, 0x04, 0x28, 0xaf, 0xd7, 0xfb, 0xca, 0xbb, 0x4b, 0x40, 0x7e
    
    XXH_SECRET_DEFAULT_SIZE = 192; % /* minimum XXH3_SECRET_SIZE_MIN */
    STRIPE_LEN = 64;
    XXH_SECRET_CONSUME_RATE = 8; % /* nb of secret bytes consumed at each accumulation */
    ACC_NB = STRIPE_LEN / 8;
    XXH3_MIDSIZE_MAX = 240;
    
    % Preallocate the shared accumulator state
    acc_u64 = zeros(ACC_NB, 1, 'uint64');
    
    % Test if not the little endian byte order
    persistent isbigendian;
    if isempty(isbigendian), %#ok
        [~, ~, endian] = computer;
        isbigendian = strcmp(endian, 'B');
    end

    
    
    %% PROCESS INPUT ARGUMENTS
    % Convert input to uint8
    if nargin < 1, input = []; end
    input_u8 = input_to_uint8(input);
    
    % Convert seed_or_secret to either uint8 or uint64 (or error)
    if nargin < 2, seed_or_secret = 0; end
    if numel(seed_or_secret) == 1, %#ok
        seed_u64 = uint64(seed_or_secret);
        secret_u8 = kSecret_u8(:);
    elseif numel(seed_or_secret) >= XXH3_SECRET_SIZE_MIN, %#ok
        seed_u64 = uint64(0);
        seed_or_secret = seed_or_secret(:); % Force column vector
        if islogical(seed_or_secret) || ischar(seed_or_secret), secret_u8 = uint8(seed_or_secret); % Handle casting of logicals and chars
        else, secret_u8 = typecast(seed_or_secret, 'uint8'); end
    else, %#ok
        error('The second parameter must either be a scalar seed or a vector secret of length %d or larger!', XXH3_SECRET_SIZE_MIN);
    end
    
    
    
    %% SHORT VS. LONG KEYS
    if numel(input_u8) <= XXH3_MIDSIZE_MAX, %#ok
        % /* Hashes a short input, <= 240 bytes */
        hash_u64 = hashShort_u64(input_u8, secret_u8, seed_u64);
    else, %#ok
        if numel(seed_or_secret) == 1, %#ok
            % /* Hashes a long input, > 240 bytes */
            secret_u8 = zeros(XXH_SECRET_DEFAULT_SIZE, 1, 'uint8');
            kSecret_u64s = typecast(kSecret_u8(1:floor(XXH_SECRET_DEFAULT_SIZE / 16)*16), 'uint64');
            if isbigendian, kSecret_u64s = swapbytes(kSecret_u64s); end % For big-endian machines
            for jj = 0:floor(XXH_SECRET_DEFAULT_SIZE / 16)-1, %#ok
                secret_u8((1:8)+16*jj) = typecast(add_u64(kSecret_u64s(2*jj+1), seed_u64), 'uint8');
                secret_u8((9:16)+16*jj) = typecast(sub_u64(kSecret_u64s(2*jj+2), seed_u64), 'uint8');
            end
        end
        hash_u64 = hashLong_u64(input_u8, secret_u8);
    end
    
    
    
    %% HANDLE INPUT
    function input_u8 = input_to_uint8(input), %#ok
        input = input(:); % Force column vector
        if iscell(input), %#ok
            input_u8 = cellfun(@input_to_uint8, input, 'UniformOutput', false);
            input_u8 = vertcat(input_u8{:});
            input_u8 = [reshape(typecast(numel(input_u8), 'uint8'), [], 1); input_u8]; % Convert cell array to unique uint8 array (by adding its numel in uint8)
        elseif islogical(input) || ischar(input), input_u8 = uint8(input); % Handle casting of logicals and chars
        else, input_u8 = typecast(input, 'uint8'); end
    end

    
    
    %% SHORT KEYS
    % /* Hashes a short input, < 240 bytes */
    function hash_u64 = hashShort_u64(input_u8, secret_u8, seed_u64), %#ok
        length = numel(input_u8);
        if length <= 16, %#ok
            % /* Hashes short keys that are less than or equal to 16 bytes. */
            if length > 8, %#ok
                % /* Hashes short keys from 9 to 16 bytes. */
                input_u64s = typecast(input_u8([1:8 end-7:end]), 'uint64');
                secret_u64s = typecast(secret_u8((1:32)+24), 'uint64');
                if isbigendian, %#ok % For big-endian machines
                    input_u64s = swapbytes(input_u64s);
                    secret_u64s = swapbytes(secret_u64s);
                end
                input_lo_u64 = bitxor(secret_u64s(1), secret_u64s(2));
                input_hi_u64 = bitxor(secret_u64s(3), secret_u64s(4));
                acc_u64 = uint64(length);
                input_lo_u64 = add_u64(input_lo_u64, seed_u64);
                input_hi_u64 = sub_u64(input_hi_u64, seed_u64);
                input_lo_u64 = bitxor(input_lo_u64, input_u64s(1));
                input_hi_u64 = bitxor(input_hi_u64, input_u64s(2));
                acc_u64 = add_u64(acc_u64, swapbytes(input_lo_u64));
                acc_u64 = add_u64(acc_u64, input_hi_u64);
                acc_u64 = add_u64(acc_u64, mul_u128_fold_u64(input_lo_u64, input_hi_u64));
                hash_u64 = avalanche_u64(acc_u64);
            elseif length >= 4, %#ok
                % /* Hashes short keys from 4 to 8 bytes. */
                input_u32s = typecast(input_u8([1:4 length-3:length]), 'uint32');
                secret_u64s = typecast(secret_u8((1:16)+8), 'uint64');
                if isbigendian, %#ok % For big-endian machines
                    input_u32s = swapbytes(input_u32s);
                    secret_u64s = swapbytes(secret_u64s);
                end
                input_hi_u32 = input_u32s(1);
                input_lo_u32 = input_u32s(2);
                input_64_u64 = bitor(uint64(input_lo_u32), bitshift(uint64(input_hi_u32), 32));
                acc_u64 = bitxor(secret_u64s(1), secret_u64s(2));
                seed_u64 = bitxor(seed_u64, bitshift(bitshift(swapbytes(seed_u64), -32), 32));
                acc_u64 = sub_u64(acc_u64, seed_u64);
                acc_u64 = bitxor(acc_u64, input_64_u64);
                % /* rrmxmx mix, skips avalanche_u64 */
                acc_u64 = bitxor(acc_u64, bitxor(bitor(bitshift(acc_u64, 49), bitshift(acc_u64, -15)), bitor(bitshift(acc_u64, 24), bitshift(acc_u64, -40)))); % Two rotate-lefts
                acc_u64 = mul_u64(acc_u64, uint64(11507291218515648293)); % 0x9FB21C651E98DF25ULL
                acc_u64 = bitxor(acc_u64, add_u64(bitshift(acc_u64, -35), uint64(length)));
                acc_u64 = mul_u64(acc_u64, uint64(11507291218515648293)); % 0x9FB21C651E98DF25ULL
                hash_u64 = bitxor(acc_u64, bitshift(acc_u64, -28));
            elseif length ~= 0, %#ok
                % /* Hashes short keys from 1 to 3 bytes. */
                secret_u32s = typecast(secret_u8(1:8), 'uint32');
                combined_u32 = typecast([input_u8(end) uint8(length) input_u8(1) input_u8(floor((1+end)/2))], 'uint32');
                if isbigendian, %#ok % For big-endian machines
                    secret_u32s = swapbytes(secret_u32s);
                    combined_u32 = swapbytes(combined_u32);
                end
                acc_u64 = uint64(bitxor(secret_u32s(1), secret_u32s(2)));
                acc_u64 = add_u64(acc_u64, seed_u64);
                acc_u64 = bitxor(acc_u64, uint64(combined_u32));
                acc_u64 = mul_u64(acc_u64, PRIME64_1);
                hash_u64 = avalanche_u64(acc_u64);
            else, %#ok
                % /* Hashes zero-length keys */
                secret_u64s = typecast(secret_u8((1:16)+56), 'uint64');
                if isbigendian, secret_u64s = swapbytes(secret_u64s); end % For big-endian machines
                acc_u64 = add_u64(seed_u64, PRIME64_1);
                acc_u64 = bitxor(acc_u64, secret_u64s(1));
                acc_u64 = bitxor(acc_u64, secret_u64s(2));
                hash_u64 = avalanche_u64(acc_u64);
            end
        elseif length <= 128, %#ok
            % /* Hashes midsize keys from 17 to 128 bytes */
            nbRounds = floor((length - 1) / 32);
            input_u64s = reshape([reshape(typecast(input_u8(1:16+nbRounds*16), 'uint64'), 2, []); fliplr(reshape(typecast(input_u8(end-15-nbRounds*16:end), 'uint64'), 2, []))], [], 1);
            secret_u64s = typecast(secret_u8(1:32+nbRounds*32), 'uint64');
            if isbigendian, %#ok % For big-endian machines
                input_u64s = swapbytes(input_u64s);
                secret_u64s = swapbytes(secret_u64s);
            end
            acc_u64 = mul_u64(uint64(length), PRIME64_1);
            % /* The primary mixer for the midsize hashes */
            lhs_u64s = bitxor(add_u64(seed_u64, secret_u64s(1:2:end-1)), input_u64s(1:2:end-1));
            rhs_u64s = bitxor(add_u64(sub_u64(uint64(0), seed_u64), secret_u64s(2:2:end)), input_u64s(2:2:end));
            mixed_u64s = mul_u128_fold_u64(lhs_u64s, rhs_u64s);
            for ii = 2*nbRounds+1:-2:1, %#ok
                acc_u64 = add_u64(acc_u64, mixed_u64s(ii));
                acc_u64 = add_u64(acc_u64, mixed_u64s(ii+1));
            end
            hash_u64 = avalanche_u64(acc_u64);
        else, %#ok
            % /* Hashes midsize keys from 129 to 240 bytes */
            XXH3_MIDSIZE_STARTOFFSET = 3;
            XXH3_MIDSIZE_LASTOFFSET = 17;
            nbRounds = floor(length / 16);
            input_u64s = typecast(input_u8([1:end-mod(length, 16) end-15:end]), 'uint64');
            secret_u64s = typecast(secret_u8([1:128 (1:(nbRounds-8)*16)+XXH3_MIDSIZE_STARTOFFSET (1:16)+XXH3_SECRET_SIZE_MIN-XXH3_MIDSIZE_LASTOFFSET]), 'uint64');
            if isbigendian, %#ok % For big-endian machines
                input_u64s = swapbytes(input_u64s);
                secret_u64s = swapbytes(secret_u64s);
            end
            acc_u64 = mul_u64(uint64(length), PRIME64_1);
            % /* The primary mixer for the midsize hashes */
            lhs_u64s = bitxor(add_u64(seed_u64, secret_u64s(1:2:end-1)), input_u64s(1:2:end-1));
            rhs_u64s = bitxor(add_u64(sub_u64(uint64(0), seed_u64), secret_u64s(2:2:end)), input_u64s(2:2:end));
            mixed_u64s = mul_u128_fold_u64(lhs_u64s, rhs_u64s);
            for ii = 1:8, acc_u64 = add_u64(acc_u64, mixed_u64s(ii)); end
            acc_u64 = avalanche_u64(acc_u64);
            % /* The primary mixer for the midsize hashes */
            for ii = 9:nbRounds, acc_u64 = add_u64(acc_u64, mixed_u64s(ii)); end
            % /* last bytes */
            % /* The primary mixer for the midsize hashes */
            lhs_u64 = bitxor(add_u64(seed_u64, secret_u64s(end-1)), input_u64s(end-1));
            rhs_u64 = bitxor(add_u64(sub_u64(uint64(0), seed_u64), secret_u64s(end)), input_u64s(end));
            acc_u64 = add_u64(acc_u64, mul_u128_fold_u64(lhs_u64, rhs_u64));
            hash_u64 = avalanche_u64(acc_u64);
        end
    end



    %% LONG KEYS
    % /* Controls the long hash function. This is used for both XXH3_64 and XXH3_128. */
    function hash_u64 = hashLong_u64(input_u8, secret_u8), %#ok
        length = numel(input_u8);
        nb_rounds = floor((numel(secret_u8) - STRIPE_LEN) / XXH_SECRET_CONSUME_RATE);
        block_len = STRIPE_LEN * nb_rounds;
        nb_blocks = floor(length / block_len);
        nb_stripes = floor((length - (block_len * nb_blocks)) / STRIPE_LEN);
        
        acc_u64(1) = PRIME32_3;
        acc_u64(2) = PRIME64_1;
        acc_u64(3) = PRIME64_2;
        acc_u64(4) = PRIME64_3;
        acc_u64(5) = PRIME64_4;
        acc_u64(6) = PRIME32_2;
        acc_u64(7) = PRIME64_5;
        acc_u64(8) = PRIME32_1;
        
        secret_u64_ACC_NB = typecast(secret_u8(end-STRIPE_LEN+1:end), 'uint64');
        secret_u64 = typecast(secret_u8(1:end-mod(end, 8)), 'uint64');
        if isbigendian, %#ok % For big-endian machines
            secret_u64_ACC_NB = swapbytes(secret_u64_ACC_NB);
            secret_u64 = swapbytes(secret_u64);
        end
        secret_u64_striped = zeros(ACC_NB, nb_rounds, 'uint64');
        for ii = 1:nb_rounds, secret_u64_striped(:,ii) = secret_u64((0:7)+ii); end
        
        % Process blocks of (approximately) 64MB or less
        MaxBlockSize = (floor(2^26./block_len)+1).*block_len; % Make MaxBlockSize divisible by block_len
        N_data_end = mod(length, MaxBlockSize);
        input_u8_MaxBlockSize_partial = input_u8(length-N_data_end+1:end);
        length_partial = numel(input_u8_MaxBlockSize_partial);
        input_u8_MaxBlockSize = reshape(input_u8(1:length-N_data_end), MaxBlockSize, []);
        N_MaxBlockSize = size(input_u8_MaxBlockSize, 2)+1;
        for mbs = 1:N_MaxBlockSize, %#ok
            if mbs == N_MaxBlockSize, input_u8_mbs = input_u8_MaxBlockSize_partial(1:end-mod(length_partial, block_len));
            else, input_u8_mbs = input_u8_MaxBlockSize(:,mbs); end % Always divisible by block_len
            length_mbs = numel(input_u8_mbs);
            nb_blocks_mbs = floor(length_mbs / block_len);
            if mbs == 1 || mbs == N_MaxBlockSize, secret_u64_striped_mbs = repmat(secret_u64_striped, [1 1 nb_blocks_mbs]); end
            
            input_u64_blocks_striped = reshape(typecast(input_u8_mbs, 'uint64'), ACC_NB, nb_rounds, nb_blocks_mbs);
            lo_hi_mul_u64_bitxor_striped = lo_hi_mul_u64(bitxor(input_u64_blocks_striped, secret_u64_striped_mbs));
            rhs_u64 = sum(reshape(uint64(typecast(lo_hi_mul_u64_bitxor_striped(:), 'uint32')) + uint64(typecast(input_u64_blocks_striped(:), 'uint32')), 2, ACC_NB, nb_rounds, nb_blocks_mbs), 3, 'native');
            rhs_u64_lo = reshape(rhs_u64(1,:), ACC_NB, nb_blocks_mbs);
            rhs_u64_hi = reshape(rhs_u64(2,:), ACC_NB, nb_blocks_mbs);
            acc_u64_lo = bitshift(bitshift(acc_u64, 32), -32);
            acc_u64_hi = bitshift(acc_u64, -32);
            secret_u64_ACC_NB_lo = bitshift(bitshift(secret_u64_ACC_NB, 32), -32);
            secret_u64_ACC_NB_hi = bitshift(secret_u64_ACC_NB, -32);
            % Useful source for optimization: https://www.chessprogramming.org/General_Setwise_Operations#Exclusive_Or
            for ii = 1:nb_blocks_mbs, %#ok % This main loop has been heavily optimized!
                % Add low and high halves per stripe
                acc_u64_lo = bitshift(bitshift(acc_u64_lo, 32), -32) + rhs_u64_lo(:,ii); % This wont overflow when high-half of acc_u64_lo is discarded
                acc_u64_hi = bitshift(bitshift(bitshift(acc_u64_lo, -32) + acc_u64_hi + rhs_u64_hi(:,ii), 32), -32); % This wont overflow even if high-half of acc_u64_hi is not discarded and all parts are maxed out
                % /* Scrambles input. This is usually written in SIMD code, as it is usually part of the main loop. */
                acc_u64_lo = bitxor(bitxor(acc_u64_lo, bitshift(acc_u64_hi, -15)), secret_u64_ACC_NB_lo);
                acc_u64_hi = bitxor(acc_u64_hi, secret_u64_ACC_NB_hi);
                % Multiply low and high halves by a prime
                acc_u64_lo = bitshift(bitshift(acc_u64_lo, 32), -32) .* PRIME32_1; % This wont overflow when high-half of acc_u64_lo is discarded
                acc_u64_hi = bitshift(acc_u64_lo, -32) + acc_u64_hi .* PRIME32_1; % This wont overflow when high-half of acc_u64_hi is discarded
            end
            acc_u64 = bitor(bitshift(bitshift(acc_u64_lo, 32), -32), bitshift(acc_u64_hi, 32));
        end
        clear secret_u64_striped input_u64_blocks_striped lo_hi_mul_u64_bitxor_striped rhs_u64;

        % /* last partial block */
        % /* Processes a full block. */
        input_u8_last_block = input_u8(1+nb_blocks*block_len:end);
        input_u64_striped = reshape(typecast(input_u8_last_block(1:nb_stripes.*STRIPE_LEN./ACC_NB.*8), 'uint64'), ACC_NB, []); %#ok
        if isbigendian, input_u64_striped = swapbytes(input_u64_striped); end % For big-endian machines
        secret_u64_striped = zeros(ACC_NB, nb_stripes, 'uint64');
        for ii = 1:nb_stripes, secret_u64_striped(:,ii) = secret_u64((0:7)+ii); end
        lo_hi_mul_u64_bitxor_striped = lo_hi_mul_u64(bitxor(input_u64_striped, secret_u64_striped));
        for ii = 1:nb_stripes, acc_u64 = add_u64_3(acc_u64, input_u64_striped(:,ii), lo_hi_mul_u64_bitxor_striped(:,ii)); end

        % /* last stripe */
        if mod(length, STRIPE_LEN) ~= 0, %#ok
            % /* Do not align on 8, so that the secret is different from the scrambler */
            XXH_SECRET_LASTACC_START = 7;
            % /* This is the main loop. This is usually written in SIMD code. */
            input_u8_last_stripe = input_u8(1+length-STRIPE_LEN:end);
            input_u64_ACC_NB = typecast(input_u8_last_stripe, 'uint64');
            secret_u64_ACC_NB = typecast(secret_u8((end-STRIPE_LEN+1:end)-XXH_SECRET_LASTACC_START), 'uint64');
            if isbigendian, %#ok % For big-endian machines
                input_u64_ACC_NB = swapbytes(input_u64_ACC_NB);
                secret_u64_ACC_NB = swapbytes(secret_u64_ACC_NB);
            end
            lo_hi_mul_u64_bitxor_ACC_NB = lo_hi_mul_u64(bitxor(input_u64_ACC_NB, secret_u64_ACC_NB));
            acc_u64 = add_u64_3(acc_u64, input_u64_ACC_NB, lo_hi_mul_u64_bitxor_ACC_NB);
        end

        XXH_SECRET_MERGEACCS_START = 11;

        % /* converge into final hash */
        % /* Combines 8 accumulators with keys into 1 finalized 64-bit hash. */
        hash_u64 = mul_u64(uint64(length), PRIME64_1);
        secret_u64s = typecast(secret_u8((1:64)+XXH_SECRET_MERGEACCS_START), 'uint64');
        if isbigendian, secret_u64s = swapbytes(secret_u64s); end % For big-endian machines
        acc_u64 = bitxor(acc_u64, secret_u64s);  % /* Combines accumulators with keys */
        for ii = 1:2:8, %#ok
            hash_u64 = add_u64(hash_u64, mul_u128_fold_u64(acc_u64(ii), acc_u64(ii+1)));
        end
        hash_u64 = avalanche_u64(hash_u64);
    end

    % /* Calculates a 64-bit to 128-bit unsigned multiply, then xor's the low bits of the product with
    %  * the high bits for a 64-bit result. */
    function result_u64 = mul_u128_fold_u64(lhs_u64, rhs_u64), %#ok
        % /* Portable scalar version */
        % /* First calculate all of the cross products. */
        lo_lo_u64 = bitshift(bitshift(lhs_u64, 32), -32) .* bitshift(bitshift(rhs_u64, 32), -32);
        hi_lo_u64 = bitshift(lhs_u64, -32) .* bitshift(bitshift(rhs_u64, 32), -32);
        lo_hi_u64 = bitshift(bitshift(lhs_u64, 32), -32) .* bitshift(rhs_u64, -32);
        hi_hi_u64 = bitshift(lhs_u64, -32) .* bitshift(rhs_u64, -32);

        % /* Now add the products together. These will never overflow. */
        cross_u64 = bitshift(lo_lo_u64, -32) + bitshift(bitshift(hi_lo_u64, 32), -32) + lo_hi_u64;
        upper_u64 = bitshift(hi_lo_u64, -32) + bitshift(cross_u64, -32) + hi_hi_u64;
        lower_u64 = bitor(bitshift(cross_u64, 32), bitshift(bitshift(lo_lo_u64, 32), -32));

        result_u64 = bitxor(upper_u64, lower_u64);
    end

    % /* Mixes up the hash to finalize */
    function hash_u64 = avalanche_u64(hash_u64), %#ok
        hash_u64 = bitxor(hash_u64, bitshift(hash_u64, -37));
        hash_u64 = mul_u64(hash_u64, uint64(1609587791953885689)); % 0x165667919E3779F9ULL
        hash_u64 = bitxor(hash_u64, bitshift(hash_u64, -32));
    end



    %% HELPER
    % wrapping unsigned 64-bit addition
    function result_u64 = add_u64(lhs_u64, rhs_u64), %#ok
        result_u64 = bitxor(bitshift(bitshift(lhs_u64, 1), -1) + bitshift(bitshift(rhs_u64, 1), -1), bitshift(bitshift(bitxor(lhs_u64, rhs_u64), -63), 63));
    end

    % wrapping unsigned 64-bit three additions
    function result_u64 = add_u64_3(lhs_u64, mhs_u64, rhs_u64), %#ok
        lo_lo_lo_u64 = bitshift(bitshift(lhs_u64, 32), -32) + bitshift(bitshift(mhs_u64, 32), -32) + bitshift(bitshift(rhs_u64, 32), -32);
        hi_hi_hi_u64 = bitshift(lhs_u64, -32) + bitshift(mhs_u64, -32) + bitshift(rhs_u64, -32);
        
        % /* Now add the products together. These will never overflow. */
        upper_u64 = bitshift(bitshift(lo_lo_lo_u64, -32) + hi_hi_hi_u64, 32);
        lower_u64 = bitshift(bitshift(lo_lo_lo_u64, 32), -32);

        result_u64 = bitor(upper_u64, lower_u64);
    end

    % wrapping unsigned 64-bit substraction
    function result_u64 = sub_u64(lhs_u64, rhs_u64), %#ok
        if lhs_u64 >= rhs_u64, result_u64 = lhs_u64-rhs_u64;
        else, result_u64 = bitcmp(rhs_u64-lhs_u64-1); end
    end

    % wrapping unsigned 64-bit multiplication
    function result_u64 = mul_u64(lhs_u64, rhs_u64), %#ok
        lo_lo_u64 = bitshift(bitshift(lhs_u64, 32), -32) .* bitshift(bitshift(rhs_u64, 32), -32);
        hi_lo_u64 = bitshift(lhs_u64, -32) .* bitshift(bitshift(rhs_u64, 32), -32);
        lo_hi_u64 = bitshift(bitshift(lhs_u64, 32), -32) .* bitshift(rhs_u64, -32);

        % /* Now add the products together. These will never overflow. */
        upper_u64 = bitshift(bitshift(lo_lo_u64, -32) + bitshift(bitshift(hi_lo_u64, 32), -32) + bitshift(bitshift(lo_hi_u64, 32), -32), 32);
        lower_u64 = bitshift(bitshift(lo_lo_u64, 32), -32);

        result_u64 = bitor(upper_u64, lower_u64);
    end

    % unsigned 64-bit multiplication (its shifted-high bits with its low bits)
    function result_u64 = lo_hi_mul_u64(val_u64), %#ok
        result_u64 = bitshift(val_u64, -32).*bitshift(bitshift(val_u64, 32), -32);
    end



    %% VERIFICATION
    function self_verification(), %#ok
        TEST_DATA_SIZE = 2243;
        PRIME64 = uint64(11400714785074694797); % 0x9e3779b185ebca8d;

        test_data = zeros(TEST_DATA_SIZE, 1, 'uint8');
        byte_gen_u64 = uint64(2654435761); % 0x9E3779B1U or 0b10011110001101110111100110110001

        % /* Fill in the test_data buffer with "random" data. */
        for ii = 0:TEST_DATA_SIZE-1, %#ok
            val_ii = typecast(bitshift(byte_gen_u64, -56), 'uint8');
            test_data(ii+1) = val_ii(1);
            byte_gen_u64 = mul_u64(byte_gen_u64, PRIME64);
        end

        secret = test_data(1+7:end);
        secret = secret(1:XXH3_SECRET_SIZE_MIN+11);
        
        % Temporarily disable backtrace
        prev_state = warning('query', 'backtrace');
        warning('off', 'backtrace');
        reset_warning_onCleanup = onCleanup(@() warning(prev_state));

        % /* xxhsum verification values */
        fprintf('Testing XXH3 (64-bit) implementation ...\n');
        test_num = 0; % The counter increased by the following calls
        
        test_sequence(0, 0, '0x776EDDFB6BFD9195ULL'); % /* empty string */
        test_sequence(0, PRIME64, '0x6AFCE90814C488CBULL');
        test_sequence(1, 0, '0xB936EBAE24CB01C5ULL'); % /*  1 -  3 */
        test_sequence(1, PRIME64, '0xF541B1905037FC39ULL'); % /*  1 -  3 */
        test_sequence(6, 0, '0x27B56A84CD2D7325ULL'); % /*  4 -  8 */
        test_sequence(6, PRIME64, '0x84589C116AB59AB9ULL'); % /*  4 -  8 */
        test_sequence(12, 0, '0xA713DAF0DFBB77E7ULL'); % /*  9 - 16 */
        test_sequence(12, PRIME64, '0xE7303E1B2336DE0EULL'); % /*  9 - 16 */
        test_sequence(24, 0, '0xA3FE70BF9D3510EBULL'); % /* 17 - 32 */
        test_sequence(24, PRIME64, '0x850E80FC35BDD690ULL'); % /* 17 - 32 */
        test_sequence(48, 0, '0x397DA259ECBA1F11ULL'); % /* 33 - 64 */
        test_sequence(48, PRIME64, '0xADC2CBAA44ACC616ULL'); % /* 33 - 64 */
        test_sequence(80, 0, '0xBCDEFBBB2C47C90AULL'); % /* 65 - 96 */
        test_sequence(80, PRIME64, '0xC6DD0CB699532E73ULL'); % /* 65 - 96 */
        test_sequence(195, 0, '0xCD94217EE362EC3AULL'); % /* 129-240 */
        test_sequence(195, PRIME64, '0xBA68003D370CB3D9ULL'); % /* 129-240 */

        test_sequence(0, secret, '0x6775FD10343C92C3ULL'); % /* empty string */
        test_sequence(1, secret, '0xC3382C326E24E3CDULL'); % /*  1 -  3 */
        test_sequence(6, secret, '0x82C90AB0519369ADULL'); % /*  4 -  8 */
        test_sequence(12, secret, '0x14631E773B78EC57ULL'); % /*  9 - 16 */
        test_sequence(24, secret, '0xCDD5542E4A9D9FE8ULL'); % /* 17 - 32 */
        test_sequence(48, secret, '0x33ABD54D094B2534ULL'); % /* 33 - 64 */
        test_sequence(80, secret, '0xE687BA1684965297ULL'); % /* 65 - 96 */
        test_sequence(195, secret, '0xA057273F5EECFB20ULL'); % /* 129-240 */

        test_sequence(403, 0, '0x1B2AFF3B46C74648ULL'); % /* one block, last stripe is overlapping */
        test_sequence(403, PRIME64, '0xB654F6FFF42AD787ULL'); % /* one block, last stripe is overlapping */
        test_sequence(512, 0, '0x43E368661808A9E8ULL'); % /* one block, finishing at stripe boundary */
        test_sequence(512, PRIME64, '0x3A865148E584E5B9ULL'); % /* one block, finishing at stripe boundary */
        test_sequence(2048, 0, '0xC7169244BBDA8BD4ULL'); % /* 2 blocks, finishing at block boundary */
        test_sequence(2048, PRIME64, '0x74BF9A802BBDFBAEULL'); % /* 2 blocks, finishing at block boundary */
        test_sequence(2240, 0, '0x30FEB637E114C0C7ULL'); % /* 3 blocks, finishing at stripe boundary */
        test_sequence(2240, PRIME64, '0xEEF78A36185EB61FULL'); % /* 3 blocks, finishing at stripe boundary */
        test_sequence(2243, 0, '0x62C631454648A193ULL'); % /* 3 blocks, last stripe is overlapping */
        test_sequence(2243, PRIME64, '0x6CF80A4BADEA4428ULL'); % /* 3 blocks, last stripe is overlapping */

        test_sequence(403, secret, '0xF9C0BA5BA3AF70B8ULL'); % /* one block, last stripe is overlapping */
        test_sequence(512, secret, '0x7896E65DCFA09071ULL'); % /* one block, finishing at stripe boundary */
        test_sequence(2048, secret, '0xD6545DB87ECFD98CULL'); % /* >= 2 blocks, at least one scrambling */
        test_sequence(2243, secret, '0x887810081C32460AULL'); % /* >= 2 blocks, at least one scrambling, last stripe unaligned */
        
        function test_sequence(N_input, seed_or_secret, expected_u64_str), %#ok
            input = test_data(1:N_input);
            test_num = test_num + 1;
            
            expected_u64 = sscanf(strrep(expected_u64_str, 'ULL', ''), '%lx');
            result_u64 = WITio.obj.wit.xxh3_64(input, seed_or_secret);
            
            if numel(seed_or_secret) ~= 1, test_str = sprintf('%d-byte input and custom %d-byte secret', numel(input), numel(seed_or_secret)); %#ok
            elseif seed_or_secret == 0, test_str = sprintf('%d-byte input and zero seed', numel(input));
            else, test_str = sprintf('%d-byte input and custom seed', numel(input)); end
            
            if result_u64 == expected_u64, fprintf('Test %i: Successful for %s!\n', test_num, test_str);
            else, warning('Test %i: 0x%016X (expected) vs. 0x%016X (actual) for the %s test!', test_num, expected_u64, result_u64, test_str); end
        end
    end
end
