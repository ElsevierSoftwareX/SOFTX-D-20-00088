file = 'test_spectral_stitch.wip';
[C_wid, C_wip, n] = wip.read(file, '-all', '-Manager', {'-Type', 'TDGraph'}, '-SpectralUnit', '(nm)');
[obj, X, Y] = C_wid.spectral_stitch('-debug');
figure; obj.plot;
