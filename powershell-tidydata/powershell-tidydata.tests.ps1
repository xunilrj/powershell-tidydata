cd (Split-Path $PSCommandPath -Parent)

Import-Module .\powershell-tidydata.psd1 -Force
Import-Module Pester

#region Datasets

$religionIncome = 'religion;<$10k;$10-20k;$20-30k;$30-40k;$40-50k;$50-75k
Agnostic;27;34;60;81;76;137
Atheist;12;27;37;52;35;70
Buddhist;27;21;30;34;33;58
Catholic;418;617;732;670;638;1116
Don''t know/refused;15;14;15;11;10;35
Evangelical Prot;575;869;1064;982;881;1486
Hindu;1;9;7;9;11;34
Historically Black Prot;228;244;236;238;197;223
Jehovah''s Witness;20;27;24;24;21;30
Jewish;19;19;25;25;30;95'

$billboard = 'year,artist,track,time,date.entered,wk1,wk2,wk3
2000, 2 Pac, Baby Don''t Cry, 4:22, 2000-02-26, 87, 82, 72
2000, 2Ge+her, The Hardest Part Of ..., 3:15, 2000-09-02, 91, 87, 92
2000, 3 Doors Down, Kryptonite, 3:53, 2000-04-08, 81, 70, 68
2000, 98^0, Give Me Just One Nig..., 3:24, 2000-08-19, 51, 39, 34
2000, A*Teens, Dancing Queen, 3:44, 2000-07-08, 97, 97, 96
2000, Aaliyah, I Don''t Wanna, 4:15, 2000-01-29, 84, 62, 51
2000, Aaliyah, Try Again, 4:03, 2000-03-18, 59, 53, 38
2000, Adams Yolanda, Open My Heart, 5:30, 2000-08-26, 76, 76, 74'

$cases = "country year m014 m1524 m2534 m3544 m4554 m5564 m65 mu f014
AD 2000 0 0 1 0 0 0 0 — —
AE 2000 2 4 4 6 5 12 10 — 3
AF 2000 52 228 183 149 129 94 80 — 93
AG 2000 0 0 0 0 0 0 1 — 1
AL 2000 2 19 21 14 24 19 16 — 3
AM 2000 2 152 130 131 63 26 21 — 1
AN 2000 0 0 1 2 0 0 0 — 0
AO 2000 186 999 1003 912 482 312 194 — 247
AR 2000 97 278 594 402 419 368 330 — 121
AS 2000 — — — — 1 1 — — —"

#endregion

Describe "Unpivot-Object" {
	Context "When column headers are values, not variable names" {
		It "must be possible to unpivot the column in key-value" {
			Mock Get-Content {$religionIncome}

			$molten = gc .\religionIncome.csv | 
                ConvertFrom-Csv -Delimiter ';' | 
                melt '<$10k','$10-20k','$20-30k','$30-40k','$40-50k','$50-75k' -As 'Income','Quantity'
            
            $molten[0].Income | Should Be '<$10k'
            $molten[1].Income | Should Be '$10-20k'
            $molten[2].Income | Should Be '$20-30k'
            $molten[3].Income | Should Be '$30-40k'
            $molten[4].Income | Should Be '$40-50k'
            $molten[5].Income | Should Be '$50-75k'

            $molten[0].Quantity | Should Be 27
            $molten[1].Quantity | Should Be 34
            $molten[2].Quantity | Should Be 60
            $molten[3].Quantity | Should Be 81
            $molten[4].Quantity | Should Be 76            
            $molten[5].Quantity | Should Be 137
		}
        It "must be possible to apply a transformation to the column name" {            
            Mock Get-Content {$billboard}

            $data = gc .\billboard.csv | ConvertFrom-Csv |
                melt wk1, wk2, wk3 -As Week,Rank -TransformKey { $_.Replace('wk','') }

            $data[0].track | Should Be 'Baby Don''t Cry'
            $data[0].Week | Should Be '1'
            $data[0].Rank | Should Be '87'

            $data[1].track | Should Be 'Baby Don''t Cry'
            $data[1].Week | Should Be '2'
            $data[1].Rank | Should Be '82'

            $data[3].track | Should Be 'The Hardest Part of ...'
            $data[3].Week | Should Be '1'
            $data[3].Rank | Should Be '91'

            $data[4].track | Should Be 'The Hardest Part of ...'
            $data[4].Week | Should Be '2'
            $data[4].Rank | Should Be '87'
        }
	}
    Context "When Multiple variables stored in one column" {        It "must be possible to split the column in two or more coluns"{            Mock Get-Content {$cases}            $data = gc .\Cases.csv |                    ConvertFrom-Csv -Delimiter ' ' |                     Unpivot-Object m014, m1524, m2534, m3544, m4554, m5564, m65, mu, f014 -As 'Columns','Cases' |                    Split-Member "Columns" "^(?<SEX>.)(?<AGE>.+)$" |                    Rename-Member "SEX" "Sex" |                    Rename-Member "AGE" "Age" |                                     Transform-Member "Cases" @{"—"=$null} |                    Cast-Member "Cases" System.Int32 |                    Transform-Member "Sex" @{"m"="MALE";"f"="FEMALE"} |                    Transform-Member "Age" @{                        "014"="00-14";                        "1524"="15-24";                        "2534"="25-34";                        "3544"="35-44";                        "4554"="45-54";                        "5564"="55-64";                        "65"="65+";                        "u"="Uninformed";}            $data[0].Sex | Should Be 'MALE'
            $data[0].Age | Should Be '00-14'
            $data[0].Cases | Should Be 0            $data[1].Sex | Should Be 'MALE'
            $data[1].Age | Should Be '15-24'
            $data[1].Cases | Should Be 0            $data[2].Sex | Should Be 'MALE'
            $data[2].Age | Should Be '25-34'
            $data[2].Cases | Should Be 1        }    }
}