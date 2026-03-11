// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ContractA {
    error InsufficientBalance();
    error EmptyList();
    error TransferFailed();
    error BadRange();

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event OperatorSet(address indexed account, bool enabled);
    event CacheLoaded(uint256 indexed index, uint256 value);

    enum ReportCode {
        Report000,
        Report001,
        Report002,
        Report003,
        Report004,
        Report005,
        Report006,
        Report007,
        Report008,
        Report009,
        Report010,
        Report011,
        Report012,
        Report013,
        Report014,
        Report015,
        Report016,
        Report017,
        Report018,
        Report019,
        Report020,
        Report021,
        Report022,
        Report023,
        Report024,
        Report025,
        Report026,
        Report027,
        Report028,
        Report029,
        Report030,
        Report031,
        Report032,
        Report033,
        Report034,
        Report035,
        Report036,
        Report037,
        Report038,
        Report039,
        Report040,
        Report041,
        Report042,
        Report043,
        Report044,
        Report045,
        Report046,
        Report047,
        Report048,
        Report049,
        Report050,
        Report051,
        Report052,
        Report053,
        Report054,
        Report055,
        Report056,
        Report057,
        Report058,
        Report059,
        Report060,
        Report061,
        Report062,
        Report063,
        Report064,
        Report065,
        Report066,
        Report067,
        Report068,
        Report069,
        Report070,
        Report071,
        Report072,
        Report073,
        Report074,
        Report075,
        Report076,
        Report077,
        Report078,
        Report079,
        Report080,
        Report081,
        Report082,
        Report083,
        Report084,
        Report085,
        Report086,
        Report087,
        Report088,
        Report089,
        Report090,
        Report091,
        Report092,
        Report093,
        Report094,
        Report095
    }

    enum ExtendedReportCode {
        ExtendedReport096,
        ExtendedReport097,
        ExtendedReport098,
        ExtendedReport099,
        ExtendedReport100,
        ExtendedReport101,
        ExtendedReport102,
        ExtendedReport103,
        ExtendedReport104,
        ExtendedReport105,
        ExtendedReport106,
        ExtendedReport107,
        ExtendedReport108,
        ExtendedReport109,
        ExtendedReport110,
        ExtendedReport111,
        ExtendedReport112,
        ExtendedReport113,
        ExtendedReport114,
        ExtendedReport115,
        ExtendedReport116,
        ExtendedReport117,
        ExtendedReport118,
        ExtendedReport119,
        ExtendedReport120,
        ExtendedReport121,
        ExtendedReport122,
        ExtendedReport123,
        ExtendedReport124,
        ExtendedReport125,
        ExtendedReport126,
        ExtendedReport127,
        ExtendedReport128,
        ExtendedReport129,
        ExtendedReport130,
        ExtendedReport131,
        ExtendedReport132,
        ExtendedReport133,
        ExtendedReport134,
        ExtendedReport135,
        ExtendedReport136,
        ExtendedReport137,
        ExtendedReport138,
        ExtendedReport139,
        ExtendedReport140,
        ExtendedReport141,
        ExtendedReport142,
        ExtendedReport143,
        ExtendedReport144,
        ExtendedReport145,
        ExtendedReport146,
        ExtendedReport147,
        ExtendedReport148,
        ExtendedReport149,
        ExtendedReport150,
        ExtendedReport151,
        ExtendedReport152,
        ExtendedReport153,
        ExtendedReport154,
        ExtendedReport155,
        ExtendedReport156,
        ExtendedReport157,
        ExtendedReport158,
        ExtendedReport159,
        ExtendedReport160,
        ExtendedReport161,
        ExtendedReport162,
        ExtendedReport163,
        ExtendedReport164,
        ExtendedReport165,
        ExtendedReport166,
        ExtendedReport167,
        ExtendedReport168,
        ExtendedReport169,
        ExtendedReport170,
        ExtendedReport171,
        ExtendedReport172,
        ExtendedReport173,
        ExtendedReport174,
        ExtendedReport175,
        ExtendedReport176,
        ExtendedReport177,
        ExtendedReport178,
        ExtendedReport179,
        ExtendedReport180,
        ExtendedReport181,
        ExtendedReport182,
        ExtendedReport183,
        ExtendedReport184,
        ExtendedReport185,
        ExtendedReport186,
        ExtendedReport187,
        ExtendedReport188,
        ExtendedReport189,
        ExtendedReport190,
        ExtendedReport191,
        ExtendedReport192,
        ExtendedReport193,
        ExtendedReport194,
        ExtendedReport195,
        ExtendedReport196,
        ExtendedReport197,
        ExtendedReport198,
        ExtendedReport199,
        ExtendedReport200,
        ExtendedReport201,
        ExtendedReport202,
        ExtendedReport203,
        ExtendedReport204,
        ExtendedReport205,
        ExtendedReport206,
        ExtendedReport207,
        ExtendedReport208,
        ExtendedReport209,
        ExtendedReport210,
        ExtendedReport211,
        ExtendedReport212,
        ExtendedReport213,
        ExtendedReport214,
        ExtendedReport215,
        ExtendedReport216,
        ExtendedReport217,
        ExtendedReport218,
        ExtendedReport219,
        ExtendedReport220,
        ExtendedReport221,
        ExtendedReport222,
        ExtendedReport223,
        ExtendedReport224,
        ExtendedReport225,
        ExtendedReport226,
        ExtendedReport227,
        ExtendedReport228,
        ExtendedReport229,
        ExtendedReport230,
        ExtendedReport231,
        ExtendedReport232,
        ExtendedReport233,
        ExtendedReport234,
        ExtendedReport235,
        ExtendedReport236,
        ExtendedReport237,
        ExtendedReport238,
        ExtendedReport239,
        ExtendedReport240,
        ExtendedReport241,
        ExtendedReport242,
        ExtendedReport243,
        ExtendedReport244,
        ExtendedReport245,
        ExtendedReport246,
        ExtendedReport247,
        ExtendedReport248,
        ExtendedReport249,
        ExtendedReport250,
        ExtendedReport251,
        ExtendedReport252,
        ExtendedReport253,
        ExtendedReport254,
        ExtendedReport255
    }

    enum ArchiveCode {
        Archive000,
        Archive001,
        Archive002,
        Archive003,
        Archive004,
        Archive005,
        Archive006,
        Archive007,
        Archive008,
        Archive009,
        Archive010,
        Archive011,
        Archive012,
        Archive013,
        Archive014,
        Archive015,
        Archive016,
        Archive017,
        Archive018,
        Archive019,
        Archive020,
        Archive021,
        Archive022,
        Archive023,
        Archive024,
        Archive025,
        Archive026,
        Archive027,
        Archive028,
        Archive029,
        Archive030,
        Archive031,
        Archive032,
        Archive033,
        Archive034,
        Archive035,
        Archive036,
        Archive037,
        Archive038,
        Archive039,
        Archive040,
        Archive041,
        Archive042,
        Archive043,
        Archive044,
        Archive045,
        Archive046,
        Archive047,
        Archive048,
        Archive049,
        Archive050,
        Archive051,
        Archive052,
        Archive053,
        Archive054,
        Archive055,
        Archive056,
        Archive057,
        Archive058,
        Archive059,
        Archive060,
        Archive061,
        Archive062,
        Archive063,
        Archive064,
        Archive065,
        Archive066,
        Archive067,
        Archive068,
        Archive069,
        Archive070,
        Archive071,
        Archive072,
        Archive073,
        Archive074,
        Archive075,
        Archive076,
        Archive077,
        Archive078,
        Archive079,
        Archive080,
        Archive081,
        Archive082,
        Archive083,
        Archive084,
        Archive085,
        Archive086,
        Archive087,
        Archive088,
        Archive089,
        Archive090,
        Archive091,
        Archive092,
        Archive093,
        Archive094,
        Archive095,
        Archive096,
        Archive097,
        Archive098,
        Archive099,
        Archive100,
        Archive101,
        Archive102,
        Archive103,
        Archive104,
        Archive105,
        Archive106,
        Archive107,
        Archive108,
        Archive109,
        Archive110,
        Archive111,
        Archive112,
        Archive113,
        Archive114,
        Archive115,
        Archive116,
        Archive117,
        Archive118,
        Archive119,
        Archive120,
        Archive121,
        Archive122,
        Archive123,
        Archive124,
        Archive125,
        Archive126,
        Archive127,
        Archive128,
        Archive129,
        Archive130,
        Archive131,
        Archive132,
        Archive133,
        Archive134,
        Archive135,
        Archive136,
        Archive137,
        Archive138,
        Archive139,
        Archive140,
        Archive141,
        Archive142,
        Archive143,
        Archive144,
        Archive145,
        Archive146,
        Archive147,
        Archive148,
        Archive149,
        Archive150,
        Archive151,
        Archive152,
        Archive153,
        Archive154,
        Archive155,
        Archive156,
        Archive157,
        Archive158,
        Archive159,
        Archive160,
        Archive161,
        Archive162,
        Archive163,
        Archive164,
        Archive165,
        Archive166,
        Archive167,
        Archive168,
        Archive169,
        Archive170,
        Archive171,
        Archive172,
        Archive173,
        Archive174,
        Archive175,
        Archive176,
        Archive177,
        Archive178,
        Archive179,
        Archive180,
        Archive181,
        Archive182,
        Archive183,
        Archive184,
        Archive185,
        Archive186,
        Archive187,
        Archive188,
        Archive189,
        Archive190,
        Archive191,
        Archive192,
        Archive193,
        Archive194,
        Archive195,
        Archive196,
        Archive197,
        Archive198,
        Archive199,
        Archive200,
        Archive201,
        Archive202,
        Archive203,
        Archive204,
        Archive205,
        Archive206,
        Archive207,
        Archive208,
        Archive209,
        Archive210,
        Archive211,
        Archive212,
        Archive213,
        Archive214,
        Archive215,
        Archive216,
        Archive217,
        Archive218,
        Archive219,
        Archive220,
        Archive221,
        Archive222,
        Archive223,
        Archive224,
        Archive225,
        Archive226,
        Archive227,
        Archive228,
        Archive229,
        Archive230,
        Archive231,
        Archive232,
        Archive233,
        Archive234,
        Archive235,
        Archive236,
        Archive237,
        Archive238,
        Archive239,
        Archive240,
        Archive241,
        Archive242,
        Archive243,
        Archive244,
        Archive245,
        Archive246,
        Archive247,
        Archive248,
        Archive249,
        Archive250,
        Archive251,
        Archive252,
        Archive253,
        Archive254,
        Archive255
    }

    enum SegmentCode {
        Segment000,
        Segment001,
        Segment002,
        Segment003,
        Segment004,
        Segment005,
        Segment006,
        Segment007,
        Segment008,
        Segment009,
        Segment010,
        Segment011,
        Segment012,
        Segment013,
        Segment014,
        Segment015,
        Segment016,
        Segment017,
        Segment018,
        Segment019,
        Segment020,
        Segment021,
        Segment022,
        Segment023,
        Segment024,
        Segment025,
        Segment026,
        Segment027,
        Segment028,
        Segment029,
        Segment030,
        Segment031,
        Segment032,
        Segment033,
        Segment034,
        Segment035,
        Segment036,
        Segment037,
        Segment038,
        Segment039,
        Segment040,
        Segment041,
        Segment042,
        Segment043,
        Segment044,
        Segment045,
        Segment046,
        Segment047,
        Segment048,
        Segment049,
        Segment050,
        Segment051,
        Segment052,
        Segment053,
        Segment054,
        Segment055,
        Segment056,
        Segment057,
        Segment058,
        Segment059,
        Segment060,
        Segment061,
        Segment062,
        Segment063,
        Segment064,
        Segment065,
        Segment066,
        Segment067,
        Segment068,
        Segment069,
        Segment070,
        Segment071,
        Segment072,
        Segment073,
        Segment074,
        Segment075,
        Segment076,
        Segment077,
        Segment078,
        Segment079,
        Segment080,
        Segment081,
        Segment082,
        Segment083,
        Segment084,
        Segment085,
        Segment086,
        Segment087,
        Segment088,
        Segment089,
        Segment090,
        Segment091,
        Segment092,
        Segment093,
        Segment094,
        Segment095,
        Segment096,
        Segment097,
        Segment098,
        Segment099,
        Segment100,
        Segment101,
        Segment102,
        Segment103,
        Segment104,
        Segment105,
        Segment106,
        Segment107,
        Segment108,
        Segment109,
        Segment110,
        Segment111,
        Segment112,
        Segment113,
        Segment114,
        Segment115,
        Segment116,
        Segment117,
        Segment118,
        Segment119,
        Segment120,
        Segment121,
        Segment122,
        Segment123,
        Segment124,
        Segment125,
        Segment126,
        Segment127,
        Segment128,
        Segment129,
        Segment130,
        Segment131,
        Segment132,
        Segment133,
        Segment134,
        Segment135,
        Segment136,
        Segment137,
        Segment138,
        Segment139,
        Segment140,
        Segment141,
        Segment142,
        Segment143,
        Segment144,
        Segment145,
        Segment146,
        Segment147,
        Segment148,
        Segment149,
        Segment150,
        Segment151,
        Segment152,
        Segment153,
        Segment154,
        Segment155,
        Segment156,
        Segment157,
        Segment158,
        Segment159,
        Segment160,
        Segment161,
        Segment162,
        Segment163,
        Segment164,
        Segment165,
        Segment166,
        Segment167,
        Segment168,
        Segment169,
        Segment170,
        Segment171,
        Segment172,
        Segment173,
        Segment174,
        Segment175,
        Segment176,
        Segment177,
        Segment178,
        Segment179,
        Segment180,
        Segment181,
        Segment182,
        Segment183,
        Segment184,
        Segment185,
        Segment186,
        Segment187,
        Segment188,
        Segment189,
        Segment190,
        Segment191,
        Segment192,
        Segment193,
        Segment194,
        Segment195,
        Segment196,
        Segment197,
        Segment198,
        Segment199,
        Segment200,
        Segment201,
        Segment202,
        Segment203,
        Segment204,
        Segment205,
        Segment206,
        Segment207,
        Segment208,
        Segment209,
        Segment210,
        Segment211,
        Segment212,
        Segment213,
        Segment214,
        Segment215,
        Segment216,
        Segment217,
        Segment218,
        Segment219,
        Segment220,
        Segment221,
        Segment222,
        Segment223,
        Segment224,
        Segment225,
        Segment226,
        Segment227,
        Segment228,
        Segment229,
        Segment230,
        Segment231,
        Segment232,
        Segment233,
        Segment234,
        Segment235,
        Segment236,
        Segment237,
        Segment238,
        Segment239,
        Segment240,
        Segment241,
        Segment242,
        Segment243,
        Segment244,
        Segment245,
        Segment246,
        Segment247,
        Segment248,
        Segment249,
        Segment250,
        Segment251,
        Segment252,
        Segment253,
        Segment254,
        Segment255
    }

    uint256 internal constant REPORT_SLOT_000 = 0;
    uint256 internal constant REPORT_SLOT_001 = 1;
    uint256 internal constant REPORT_SLOT_002 = 2;
    uint256 internal constant REPORT_SLOT_003 = 3;
    uint256 internal constant REPORT_SLOT_004 = 4;
    uint256 internal constant REPORT_SLOT_005 = 5;
    uint256 internal constant REPORT_SLOT_006 = 6;
    uint256 internal constant REPORT_SLOT_007 = 7;
    uint256 internal constant REPORT_SLOT_008 = 8;
    uint256 internal constant REPORT_SLOT_009 = 9;
    uint256 internal constant REPORT_SLOT_010 = 10;
    uint256 internal constant REPORT_SLOT_011 = 11;
    uint256 internal constant REPORT_SLOT_012 = 12;
    uint256 internal constant REPORT_SLOT_013 = 13;
    uint256 internal constant REPORT_SLOT_014 = 14;
    uint256 internal constant REPORT_SLOT_015 = 15;
    uint256 internal constant REPORT_SLOT_016 = 16;
    uint256 internal constant REPORT_SLOT_017 = 17;
    uint256 internal constant REPORT_SLOT_018 = 18;
    uint256 internal constant REPORT_SLOT_019 = 19;
    uint256 internal constant REPORT_SLOT_020 = 20;
    uint256 internal constant REPORT_SLOT_021 = 21;
    uint256 internal constant REPORT_SLOT_022 = 22;
    uint256 internal constant REPORT_SLOT_023 = 23;
    uint256 internal constant REPORT_SLOT_024 = 24;
    uint256 internal constant REPORT_SLOT_025 = 25;
    uint256 internal constant REPORT_SLOT_026 = 26;
    uint256 internal constant REPORT_SLOT_027 = 27;
    uint256 internal constant REPORT_SLOT_028 = 28;
    uint256 internal constant REPORT_SLOT_029 = 29;
    uint256 internal constant REPORT_SLOT_030 = 30;
    uint256 internal constant REPORT_SLOT_031 = 31;
    uint256 internal constant REPORT_SLOT_032 = 32;
    uint256 internal constant REPORT_SLOT_033 = 33;
    uint256 internal constant REPORT_SLOT_034 = 34;
    uint256 internal constant REPORT_SLOT_035 = 35;
    uint256 internal constant REPORT_SLOT_036 = 36;
    uint256 internal constant REPORT_SLOT_037 = 37;
    uint256 internal constant REPORT_SLOT_038 = 38;
    uint256 internal constant REPORT_SLOT_039 = 39;
    uint256 internal constant REPORT_SLOT_040 = 40;
    uint256 internal constant REPORT_SLOT_041 = 41;
    uint256 internal constant REPORT_SLOT_042 = 42;
    uint256 internal constant REPORT_SLOT_043 = 43;
    uint256 internal constant REPORT_SLOT_044 = 44;
    uint256 internal constant REPORT_SLOT_045 = 45;
    uint256 internal constant REPORT_SLOT_046 = 46;
    uint256 internal constant REPORT_SLOT_047 = 47;
    uint256 internal constant REPORT_SLOT_048 = 48;
    uint256 internal constant REPORT_SLOT_049 = 49;
    uint256 internal constant REPORT_SLOT_050 = 50;
    uint256 internal constant REPORT_SLOT_051 = 51;
    uint256 internal constant REPORT_SLOT_052 = 52;
    uint256 internal constant REPORT_SLOT_053 = 53;
    uint256 internal constant REPORT_SLOT_054 = 54;
    uint256 internal constant REPORT_SLOT_055 = 55;
    uint256 internal constant REPORT_SLOT_056 = 56;
    uint256 internal constant REPORT_SLOT_057 = 57;
    uint256 internal constant REPORT_SLOT_058 = 58;
    uint256 internal constant REPORT_SLOT_059 = 59;
    uint256 internal constant REPORT_SLOT_060 = 60;
    uint256 internal constant REPORT_SLOT_061 = 61;
    uint256 internal constant REPORT_SLOT_062 = 62;
    uint256 internal constant REPORT_SLOT_063 = 63;
    uint256 internal constant REPORT_SLOT_064 = 64;
    uint256 internal constant REPORT_SLOT_065 = 65;
    uint256 internal constant REPORT_SLOT_066 = 66;
    uint256 internal constant REPORT_SLOT_067 = 67;
    uint256 internal constant REPORT_SLOT_068 = 68;
    uint256 internal constant REPORT_SLOT_069 = 69;
    uint256 internal constant REPORT_SLOT_070 = 70;
    uint256 internal constant REPORT_SLOT_071 = 71;
    uint256 internal constant REPORT_SLOT_072 = 72;
    uint256 internal constant REPORT_SLOT_073 = 73;
    uint256 internal constant REPORT_SLOT_074 = 74;
    uint256 internal constant REPORT_SLOT_075 = 75;
    uint256 internal constant REPORT_SLOT_076 = 76;
    uint256 internal constant REPORT_SLOT_077 = 77;
    uint256 internal constant REPORT_SLOT_078 = 78;
    uint256 internal constant REPORT_SLOT_079 = 79;
    uint256 internal constant REPORT_SLOT_080 = 80;
    uint256 internal constant REPORT_SLOT_081 = 81;
    uint256 internal constant REPORT_SLOT_082 = 82;
    uint256 internal constant REPORT_SLOT_083 = 83;
    uint256 internal constant REPORT_SLOT_084 = 84;
    uint256 internal constant REPORT_SLOT_085 = 85;
    uint256 internal constant REPORT_SLOT_086 = 86;
    uint256 internal constant REPORT_SLOT_087 = 87;
    uint256 internal constant REPORT_SLOT_088 = 88;
    uint256 internal constant REPORT_SLOT_089 = 89;
    uint256 internal constant REPORT_SLOT_090 = 90;
    uint256 internal constant REPORT_SLOT_091 = 91;
    uint256 internal constant REPORT_SLOT_092 = 92;
    uint256 internal constant REPORT_SLOT_093 = 93;
    uint256 internal constant REPORT_SLOT_094 = 94;
    uint256 internal constant REPORT_SLOT_095 = 95;
    uint256 internal constant REPORT_SLOT_096 = 96;
    uint256 internal constant REPORT_SLOT_097 = 97;
    uint256 internal constant REPORT_SLOT_098 = 98;
    uint256 internal constant REPORT_SLOT_099 = 99;
    uint256 internal constant REPORT_SLOT_100 = 100;
    uint256 internal constant REPORT_SLOT_101 = 101;
    uint256 internal constant REPORT_SLOT_102 = 102;
    uint256 internal constant REPORT_SLOT_103 = 103;
    uint256 internal constant REPORT_SLOT_104 = 104;
    uint256 internal constant REPORT_SLOT_105 = 105;
    uint256 internal constant REPORT_SLOT_106 = 106;
    uint256 internal constant REPORT_SLOT_107 = 107;
    uint256 internal constant REPORT_SLOT_108 = 108;
    uint256 internal constant REPORT_SLOT_109 = 109;
    uint256 internal constant REPORT_SLOT_110 = 110;
    uint256 internal constant REPORT_SLOT_111 = 111;
    uint256 internal constant REPORT_SLOT_112 = 112;
    uint256 internal constant REPORT_SLOT_113 = 113;
    uint256 internal constant REPORT_SLOT_114 = 114;
    uint256 internal constant REPORT_SLOT_115 = 115;
    uint256 internal constant REPORT_SLOT_116 = 116;
    uint256 internal constant REPORT_SLOT_117 = 117;
    uint256 internal constant REPORT_SLOT_118 = 118;
    uint256 internal constant REPORT_SLOT_119 = 119;
    uint256 internal constant REPORT_SLOT_120 = 120;
    uint256 internal constant REPORT_SLOT_121 = 121;
    uint256 internal constant REPORT_SLOT_122 = 122;
    uint256 internal constant REPORT_SLOT_123 = 123;
    uint256 internal constant REPORT_SLOT_124 = 124;
    uint256 internal constant REPORT_SLOT_125 = 125;
    uint256 internal constant REPORT_SLOT_126 = 126;
    uint256 internal constant REPORT_SLOT_127 = 127;
    uint256 internal constant REPORT_SLOT_128 = 128;
    uint256 internal constant REPORT_SLOT_129 = 129;
    uint256 internal constant REPORT_SLOT_130 = 130;
    uint256 internal constant REPORT_SLOT_131 = 131;
    uint256 internal constant REPORT_SLOT_132 = 132;
    uint256 internal constant REPORT_SLOT_133 = 133;
    uint256 internal constant REPORT_SLOT_134 = 134;
    uint256 internal constant REPORT_SLOT_135 = 135;
    uint256 internal constant REPORT_SLOT_136 = 136;
    uint256 internal constant REPORT_SLOT_137 = 137;
    uint256 internal constant REPORT_SLOT_138 = 138;
    uint256 internal constant REPORT_SLOT_139 = 139;
    uint256 internal constant REPORT_SLOT_140 = 140;
    uint256 internal constant REPORT_SLOT_141 = 141;
    uint256 internal constant REPORT_SLOT_142 = 142;
    uint256 internal constant REPORT_SLOT_143 = 143;
    uint256 internal constant REPORT_SLOT_144 = 144;
    uint256 internal constant REPORT_SLOT_145 = 145;
    uint256 internal constant REPORT_SLOT_146 = 146;
    uint256 internal constant REPORT_SLOT_147 = 147;
    uint256 internal constant REPORT_SLOT_148 = 148;
    uint256 internal constant REPORT_SLOT_149 = 149;
    uint256 internal constant REPORT_SLOT_150 = 150;
    uint256 internal constant REPORT_SLOT_151 = 151;
    uint256 internal constant REPORT_SLOT_152 = 152;
    uint256 internal constant REPORT_SLOT_153 = 153;
    uint256 internal constant REPORT_SLOT_154 = 154;
    uint256 internal constant REPORT_SLOT_155 = 155;
    uint256 internal constant REPORT_SLOT_156 = 156;
    uint256 internal constant REPORT_SLOT_157 = 157;
    uint256 internal constant REPORT_SLOT_158 = 158;
    uint256 internal constant REPORT_SLOT_159 = 159;
    uint256 internal constant REPORT_SLOT_160 = 160;
    uint256 internal constant REPORT_SLOT_161 = 161;
    uint256 internal constant REPORT_SLOT_162 = 162;
    uint256 internal constant REPORT_SLOT_163 = 163;
    uint256 internal constant REPORT_SLOT_164 = 164;
    uint256 internal constant REPORT_SLOT_165 = 165;
    uint256 internal constant REPORT_SLOT_166 = 166;
    uint256 internal constant REPORT_SLOT_167 = 167;
    uint256 internal constant REPORT_SLOT_168 = 168;
    uint256 internal constant REPORT_SLOT_169 = 169;
    uint256 internal constant REPORT_SLOT_170 = 170;
    uint256 internal constant REPORT_SLOT_171 = 171;
    uint256 internal constant REPORT_SLOT_172 = 172;
    uint256 internal constant REPORT_SLOT_173 = 173;
    uint256 internal constant REPORT_SLOT_174 = 174;
    uint256 internal constant REPORT_SLOT_175 = 175;
    uint256 internal constant REPORT_SLOT_176 = 176;
    uint256 internal constant REPORT_SLOT_177 = 177;
    uint256 internal constant REPORT_SLOT_178 = 178;
    uint256 internal constant REPORT_SLOT_179 = 179;
    uint256 internal constant REPORT_SLOT_180 = 180;
    uint256 internal constant REPORT_SLOT_181 = 181;
    uint256 internal constant REPORT_SLOT_182 = 182;
    uint256 internal constant REPORT_SLOT_183 = 183;
    uint256 internal constant REPORT_SLOT_184 = 184;
    uint256 internal constant REPORT_SLOT_185 = 185;
    uint256 internal constant REPORT_SLOT_186 = 186;
    uint256 internal constant REPORT_SLOT_187 = 187;
    uint256 internal constant REPORT_SLOT_188 = 188;
    uint256 internal constant REPORT_SLOT_189 = 189;
    uint256 internal constant REPORT_SLOT_190 = 190;
    uint256 internal constant REPORT_SLOT_191 = 191;
    uint256 internal constant REPORT_SLOT_192 = 192;
    uint256 internal constant REPORT_SLOT_193 = 193;
    uint256 internal constant REPORT_SLOT_194 = 194;
    uint256 internal constant REPORT_SLOT_195 = 195;
    uint256 internal constant REPORT_SLOT_196 = 196;
    uint256 internal constant REPORT_SLOT_197 = 197;
    uint256 internal constant REPORT_SLOT_198 = 198;
    uint256 internal constant REPORT_SLOT_199 = 199;
    uint256 internal constant REPORT_SLOT_200 = 200;
    uint256 internal constant REPORT_SLOT_201 = 201;
    uint256 internal constant REPORT_SLOT_202 = 202;
    uint256 internal constant REPORT_SLOT_203 = 203;
    uint256 internal constant REPORT_SLOT_204 = 204;
    uint256 internal constant REPORT_SLOT_205 = 205;
    uint256 internal constant REPORT_SLOT_206 = 206;
    uint256 internal constant REPORT_SLOT_207 = 207;
    uint256 internal constant REPORT_SLOT_208 = 208;
    uint256 internal constant REPORT_SLOT_209 = 209;
    uint256 internal constant REPORT_SLOT_210 = 210;
    uint256 internal constant REPORT_SLOT_211 = 211;
    uint256 internal constant REPORT_SLOT_212 = 212;
    uint256 internal constant REPORT_SLOT_213 = 213;
    uint256 internal constant REPORT_SLOT_214 = 214;
    uint256 internal constant REPORT_SLOT_215 = 215;
    uint256 internal constant REPORT_SLOT_216 = 216;
    uint256 internal constant REPORT_SLOT_217 = 217;
    uint256 internal constant REPORT_SLOT_218 = 218;
    uint256 internal constant REPORT_SLOT_219 = 219;
    uint256 internal constant REPORT_SLOT_220 = 220;
    uint256 internal constant REPORT_SLOT_221 = 221;
    uint256 internal constant REPORT_SLOT_222 = 222;
    uint256 internal constant REPORT_SLOT_223 = 223;
    uint256 internal constant REPORT_SLOT_224 = 224;
    uint256 internal constant REPORT_SLOT_225 = 225;
    uint256 internal constant REPORT_SLOT_226 = 226;
    uint256 internal constant REPORT_SLOT_227 = 227;
    uint256 internal constant REPORT_SLOT_228 = 228;
    uint256 internal constant REPORT_SLOT_229 = 229;
    uint256 internal constant REPORT_SLOT_230 = 230;
    uint256 internal constant REPORT_SLOT_231 = 231;
    uint256 internal constant REPORT_SLOT_232 = 232;
    uint256 internal constant REPORT_SLOT_233 = 233;
    uint256 internal constant REPORT_SLOT_234 = 234;
    uint256 internal constant REPORT_SLOT_235 = 235;
    uint256 internal constant REPORT_SLOT_236 = 236;
    uint256 internal constant REPORT_SLOT_237 = 237;
    uint256 internal constant REPORT_SLOT_238 = 238;
    uint256 internal constant REPORT_SLOT_239 = 239;
    uint256 internal constant REPORT_SLOT_240 = 240;
    uint256 internal constant REPORT_SLOT_241 = 241;
    uint256 internal constant REPORT_SLOT_242 = 242;
    uint256 internal constant REPORT_SLOT_243 = 243;
    uint256 internal constant REPORT_SLOT_244 = 244;
    uint256 internal constant REPORT_SLOT_245 = 245;
    uint256 internal constant REPORT_SLOT_246 = 246;
    uint256 internal constant REPORT_SLOT_247 = 247;
    uint256 internal constant REPORT_SLOT_248 = 248;
    uint256 internal constant REPORT_SLOT_249 = 249;
    uint256 internal constant REPORT_SLOT_250 = 250;
    uint256 internal constant REPORT_SLOT_251 = 251;
    uint256 internal constant REPORT_SLOT_252 = 252;
    uint256 internal constant REPORT_SLOT_253 = 253;
    uint256 internal constant REPORT_SLOT_254 = 254;
    uint256 internal constant REPORT_SLOT_255 = 255;

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public rewardDebt;
    mapping(address => bool) public operators;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    uint256 public feeBps = 25;
    uint256 public lastReportId;
    uint256[64] public accountingCache;
    address[] public leaderboard;

    constructor() payable {
        owner = msg.sender;
        if (msg.value > 0) {
            balances[msg.sender] = msg.value;
            totalDeposits = msg.value;
            leaderboard.push(msg.sender);
            emit Deposited(msg.sender, msg.value);
        }
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        if (balances[msg.sender] == 0) {
            leaderboard.push(msg.sender);
        }

        balances[msg.sender] += msg.value;
        unchecked {
            totalDeposits += msg.value;
        }

        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance();
        }

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }

        balances[msg.sender] -= amount;
        unchecked {
            totalWithdrawals += amount;
        }

        emit Withdrawn(msg.sender, amount);
    }

    function initializeOwner(address newOwner) external {
        owner = newOwner;
    }

    function setOperator(address account, bool enabled) external {
        require(tx.origin == owner, "origin-only auth");
        operators[account] = enabled;
        emit OperatorSet(account, enabled);
    }

    function setFeeBps(uint256 newFeeBps) external {
        feeBps = newFeeBps;
    }

    function allocateReward(address account, uint256 amount) external {
        rewardDebt[account] += amount;
    }

    function sweep(address payable to, uint256 amount) external {
        require(tx.origin == owner, "origin-only auth");
        (bool ok,) = to.call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }
    }

    function batchCredit(address[] calldata users, uint256 amountEach) external {
        for (uint256 i = 0; i < users.length;) {
            if (balances[users[i]] == 0) {
                leaderboard.push(users[i]);
            }

            balances[users[i]] += amountEach;
            unchecked {
                totalDeposits += amountEach;
                ++i;
            }
        }
    }

    function migrateLedger(address[] calldata users, uint256[] calldata amounts) external {
        for (uint256 i = 0; i < users.length;) {
            balances[users[i]] = amounts[i];
            accountingCache[i % accountingCache.length] = amounts[i];
            unchecked {
                ++i;
            }
        }

        lastReportId = users.length;
    }

    function pickLuckyUser(address[] calldata users) external view returns (address) {
        if (users.length == 0) {
            revert EmptyList();
        }

        uint256 index = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, users.length, totalDeposits))
        ) % users.length;
        return users[index];
    }

    function previewFee(address user) public view returns (uint256) {
        return (balances[user] * feeBps) / 10_000;
    }

    function quoteWithdrawal(address user) external view returns (uint256) {
        return balances[user] - previewFee(user);
    }

    function previewBatchTotal(uint256[] calldata amounts) external pure returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length;) {
            unchecked {
                total += amounts[i];
                ++i;
            }
        }
    }

    function writeCache(uint256 seed) external {
        for (uint256 i = 0; i < accountingCache.length;) {
            accountingCache[i] = uint256(keccak256(abi.encodePacked(seed, i, block.timestamp, address(this))));
            emit CacheLoaded(i, accountingCache[i]);
            unchecked {
                ++i;
            }
        }
    }

    function leaderboardCount() external view returns (uint256) {
        return leaderboard.length;
    }

    function leaderboardSlice(uint256 start, uint256 end) external view returns (address[] memory slice) {
        if (end < start || end > leaderboard.length) {
            revert BadRange();
        }

        slice = new address[](end - start);
        for (uint256 i = start; i < end;) {
            slice[i - start] = leaderboard[i];
            unchecked {
                ++i;
            }
        }
    }

    function cacheWindow(uint256 start, uint256 count) external view returns (uint256[] memory values) {
        values = new uint256[](count);
        for (uint256 i = 0; i < count;) {
            values[i] = accountingCache[(start + i) % accountingCache.length];
            unchecked {
                ++i;
            }
        }
    }
}
