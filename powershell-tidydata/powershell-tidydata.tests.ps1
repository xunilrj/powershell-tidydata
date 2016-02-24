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

#endregion

Describe "Unpivot-Object" {
	Context "When Variables are in columns" {
		It "Turns them in key-value" {
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

        It "Allow a transformation to the Key Name" {            
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
}