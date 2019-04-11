file = 'test_spectral_stitch.wip';
[C_wid, C_wip, n] = wip.read(file, '-all', '-Manager', {'-Type', 'TDGraph'}, '-SpectralUnit', '(nm)');
[obj, X, Y] = spectral_stitch(C_wid, '-debug');
figure; obj.plot;
