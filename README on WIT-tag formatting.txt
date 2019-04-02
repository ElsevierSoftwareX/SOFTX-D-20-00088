===========================================================================
%% Formatting of WIP/WID-files for versions 5-7. Listing is NOT exhaustive!
%% This represents a WIT tree structure consisting of many WIT-branches.
%% v5 = i.e. WITec Control 1.60.3.3 and Project 2.10.3.3
%% v6 = i.e. WITec Project FOUR 4.1.12
%% v7 = i.e. WITec Suite (Control + Project) FIVE 5.1.8.64
===========================================================================

***************************************************************************
%% Last updated 8.1.2019 by Joonas T. Holmi
***************************************************************************

MAGIC string (1x8 char) in the beginning of the WIP/WID-files:
	= 'WIT_PRCT'/'WIT_DATA' (v5)
	= 'WIT_PR06'/'WIT_DA06' (v6,v7)

As far as the author knows, the file format is always LITTLE ENDIAN ORDERED

===========================================================================
%% MAIN STRUCTURE of WIP-files
===========================================================================

WITec Project (wit)
    Version (int32) = 5 (v5), = 6 (v6), = 7 (v7)
    SystemInformation (wit)
        LastApplicationSessionIDs (wit)
            ...
		ServiceID (char) (v6,v7)
		LicenseID (char) (v6,v7)
		SystemID (char) (v7)
        ApplicationVersions (wit)
            ...
    NextDataID (int32)
    ShellExtensionInfo (wit)
        ThumbnailPreviewBitmap (wit)
            SizeX (int32)
            SizeY (int32)
            BitsPerPixel (int32)
            BitmapData (uint8)
    Data (wit)
        DataClassName 0 (char)
        Data 0 (wit)
            TData (wit)
            ...
        ...
        NumberOfData (int32)
    Viewer (wit)
        ViewerClassName 0 (char)
        Viewer 0 (wit)
            ...
        ...
        NumberOfViewer (int32)



===========================================================================
%% MAIN STRUCTURE of WID-files
===========================================================================

WITec Data (wit)
    Version (int32) = 5 (v5), = 6 (v6), = 7 (v7)
    SystemInformation (wit)
        LastApplicationSessionIDs (wit)
            ...
		ServiceID (char) (v6,v7)
		LicenseID (char) (v6,v7)
		SystemID (char) (v7)
        ApplicationVersions (wit)
            ...
    Data (wit)
        DataClassName 0 (char)
        Data 0 (wit)
            TData (wit)
            ...
        ...
        NumberOfData (int32)



***************************************************************************
%% DATA-SEGMENT
***************************************************************************

===========================================================================
%% Each "Data <integer>"-tag includes a TData-tag (TO BE EXCLUDED LATER!):
===========================================================================

TData (wit)
	Version (int32) = 0 (v5,v6,v7)
	ID (int32)
	ImageIndex (int32)
	Caption (char)
	MetaData (wit) (v7)
		...
	HistoryList (wit)
		Number Of History Entries (int32)
		Dates (uint32 if empty, but uint16 otherwise)
		Histories (char)
		Types (int32)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDBitmap":
===========================================================================

TDStream (wit) (v5)
	Version (int32) = 0 (v5)
	StreamSize (int32)
	StreamData (uint8) (has BMP-formatting)
TDBitmap (wit)
	Version (int32) = 0 (v5), = 1 (v6,v7)
	SizeX (int32) (v6,v7)
	SizeY (int32) (v6,v7)
	SpaceTransformationID (int32)
	SecondaryTransformationID (int32) (v7)
	BitmapData (wit) (v6,v7)
		Dimension (int32)
		DataType (int32) = 2 (v6,v7), (means that Data is int32)
		Ranges (int32)
		Data (determined by DataType) (has 32 bits per pixel)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDGraph":
===========================================================================

TDGraph (wit)
	Version (int32) = 0 (v5,v6), = 1 (v7)
	SizeX (int32)
	SizeY (int32)
	SizeGraph (int32)
	SpaceTransformationID (int32)
	SecondaryTransformationID (int32) (v7)
	XTransformationID (int32)
	XInterpretationID (int32)
	ZInterpretationID (int32)
	DataFieldInverted (logical) (v7)
	GraphData (wit)
		Dimension (int32)
		DataType (int32)
		Ranges (int32)
		Data (determined by DataType)
	LineChanged (logical)
	LineValid (logical)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDImage":
===========================================================================

TDImage (wit)
	Version (int32) = 0 (v5), = 1 (v6,v7)
	SizeX (int32)
	SizeY (int32)
	PositionTransformationID (int32)
	SecondaryTransformationID (int32) (v7)
	ZInterpretationID (int32)
	Average (double)
	Deviation (double)
	LineAverage (double)
	LineSumSqr (double)
	LineSum (double)
	LineA (double)
	LineB (double)
	LineChanged (logical)
	LineValid (logical)
	ImageDataIsInverted (logical) (v6,v7)
	ImageData (wit)
		Dimension (int32)
		DataType (int32)
		Ranges (int32)
		Data (determined by DataType)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDText":
===========================================================================

TDStream (wit)
	Version (int32) = 0 (v5,v6,v7)
	StreamSize (int32)
	StreamData (uint8) (has RTF-formatting)



***************************************************************************
%% INTERPRETATIONS
***************************************************************************

UnitIndex (TDInterpretation<TDSpaceInterpretation)
0 m
1 mm
2 µm
3 nm
4 Å
5 pm
>5 a.u. (but in µm)

UnitIndex (TDInterpretation<TDSpectralInterpretation)
0 nm
1 µm
2 1/cm
3 rel. 1/cm
4 eV
5 meV
6 rel. eV
7 rel. meV
>7 a.u. (but in nm)

UnitIndex (TDInterpretation<TDTimeInterpretation)
0 h
1 min
2 s
3 ms
4 µs
5 ns
6 ps
7 fs
>7 a.u. (but in s)

UnitIndex (TDInterpretation<TDZInterpretation)
0 UnitName<TDZInterpretation<TDZInterpretation
>0 a.u.

===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDSpaceInterpretation" and "TDTimeInterpretation":
===========================================================================

TDInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	UnitIndex (int32)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDSpectralInterpretation":
===========================================================================

TDInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	UnitIndex (int32)
TDSpectralInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	ExcitationWaveLength (double)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDZInterpretation":
===========================================================================

TDInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	UnitIndex (int32)
TDZInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	UnitName (char)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDSpectralInterpretation":
===========================================================================

TDInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	UnitIndex (int32)
TDSpectralInterpretation (wit)
	Version (int32) = 0 (v5,v6,v7)
	ExcitationWaveLength (double)



***************************************************************************
%% TRANSFORMATIONS
***************************************************************************

UnitKind
0 ?
1 StandardUnit (µm) (TDTransformation<TDSpaceTransformation)
2 StandardUnit (nm) (TDTransformation<TDSpectralTransformation)
3 StandardUnit (s) (TDTransformation<TDLinearTransformation)
4 StandardUnit (a.u.) (TDTransformation<TDLinearTransformation)
5 ?
6 StandardUnit (1/µm) (TDTransformation<TDSpaceTransformation)
...

===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDLinearTransformation":
===========================================================================

TDTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	StandardUnit (char)
	UnitKind (int32)
	InterpretationID (int32)
	IsCalibrated (logical)
TDLinearTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	ModelOrigin_D (double)
	WorldOrigin_D (double)
	Scale_D (double)
	ModelOrigin (single)
	WorldOrigin (single)
	Scale (single)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDLUTTransformation":
===========================================================================

TDTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	StandardUnit (char)
	UnitKind (int32)
	InterpretationID (int32)
	IsCalibrated (logical)
TDLUTTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	LUTSize (int32)
	LUT (double)
	LUTIsIncreasing (logical)
	



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDSpaceTransformation":
===========================================================================

TDTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	StandardUnit (char)
	UnitKind (int32)
	InterpretationID (int32)
	IsCalibrated (logical)
TDSpaceTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	ViewPort3D (wit)
		ModelOrigin (1x3 double)
		WorldOrigin (1x3 double)
		Scale (3x3 double)
		Rotation (3x3 double)
	LineInformationValid (logical)
	LineStart_D (Nx3 double)
	LineStart (Nx3 single)
	LineStop_D (Nx3 double)
	LineStop (Nx3 single)
	NumberOfLinePoints (int32)

%% MORE INFORMATION:
TData
    ImageIndex = 0 (for Image, Line, Point), = 1 (for Cross-section)



===========================================================================
%% Content of "Data <integer>"-tag with ClassName of "TDSpectralTransformation":
===========================================================================

TDTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	StandardUnit (char)
	UnitKind (int32)
	InterpretationID (int32)
	IsCalibrated (logical)
TDSpectralTransformation (wit)
	Version (int32) = 0 (v5,v6,v7)
	SpectralTransformationType (int32)
	Polynom (1x3 double) (supports the 2nd order polynomial)
	nC (double)
	LambdaC (double)
	Gamma (double)
	Delta (double)
	m (double)
	d (double)
	x (double)
	f (double)
	FreePolynomOrder (int32)
	FreePolynomStartBin (double)
	FreePolynomStopBin (double)
	FreePolynom (double)


