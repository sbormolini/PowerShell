function Add-One 
{
    param 
    (
        [int]$Number
    )
    return (++$Number)
}