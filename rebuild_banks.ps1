$seed=42
$rng=[System.Random]::new($seed)
$sizes=@{"gaokao"=350;"cet4"=500;"cet6"=450;"ielts"=400}
$results=@{}

foreach ($n in @("gaokao","cet4","cet6","ielts")) {
    $s=$sizes[$n]
    $path="C:\Users\Administrator\AppData\Local\Temp\$n.txt"
    $lines=[System.IO.File]::ReadAllLines($path,[System.Text.Encoding]::UTF8)
    $count=[Math]::Min($s,$lines.Length)
    $indices=0..($lines.Length-1)
    $selected=$indices|Sort-Object{$rng.Next()}|Select-Object -First $count
    $entries=@()
    foreach ($i in $selected) {
        $line=$lines[$i]
        $parts=$line.Split("`t")
        if ($parts.Length -ge 2) {
            $word=$parts[0].Trim()
            $def=($parts[1] -split "[；;]")[0].Trim()
            if ($word -and $def -and $word -match "^[a-zA-Z]") {
                $ew=$word -replace "'","\'"
                $ed=$def -replace "'","\'"
                $entries+="{en:'$ew',cn:'$ed'}"
            }
        }
    }
    $results[$n]=$entries -join ","
    Write-Output "$n count: $($entries.Count)"
}

$html=[System.IO.File]::ReadAllText("C:\Users\Administrator\projects\word-game\index.html",[System.Text.Encoding]::UTF8)
$pos=$html.IndexOf("const BANKS={")
$end=$html.IndexOf("};",$pos)+2
$before=$html.Substring(0,$pos)
$after=$html.Substring($end)
$newBanks="const BANKS={gaokao:[$($results['gaokao'])],cet4:[$($results['cet4'])],cet6:[$($results['cet6'])],ielts:[$($results['ielts'])]};"
[System.IO.File]::WriteAllText("C:\Users\Administrator\projects\word-game\index.html",$before+$newBanks+$after,[System.Text.Encoding]::UTF8)
$len=(Get-Item "C:\Users\Administrator\projects\word-game\index.html").Length
Write-Output "File size: $len bytes"
