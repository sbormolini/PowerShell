function Get-RelatedObjectFromSMObject
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
            [System.Object]$SMObject,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
            [System.Object]$SMRelationship,

        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Source", "Target")]
            [System.String]$Direction
    )

    $items = @()
    $relatedObjects = $null
    switch ($Direction)
    {
        'Source' 
        {
            $relatedObjects = Get-SCSMRelationshipObject -BySource $SMObject | 
                Where-Object {
                    ($_.RelationshipId -eq $SMRelationship.Id) -and
                    ($_.IsDeleted -eq $false)
            }
            $rev_direction = "TargetObject"
        }
        'Target' 
        {
            $relatedObjects = Get-SCSMRelationshipObject -ByTarget $SMObject | 
                Where-Object {
                    ($_.RelationshipId -eq $SMRelationship.Id) -and
                    ($_.IsDeleted -eq $false)
            }
            $rev_direction = "SourceObject"
        }
    }
    foreach ($item in $relatedObjects)
    {
        $items += Get-SCSMObject -Id $item.$($rev_direction).Id.Guid
    }
    return $items                 
}

function Get-SMObjectFromUserInputQuestion
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
            [System.String]$UserInputString,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
            [System.String]$Question
    )

    $items = @()
    [xml]$userinput = $UserInputString
    $value = $userinput.UserInputs.UserInput | Where-Object { $_.Question -like $Question }
    if ($value)
    { 
        [xml]$answer = $value.Answer
        foreach ($item in $answer.Values.Value)
        {
            $items += Get-SCSMObject -Id $item.InternalId
        }
    }
    return $items                 
}

function Get-AllActivitesFromWorkItem 
{ 
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
            [System.Object]$WorkItem
    ) 

    $activites = Get-RelatedObjectFromSMObject  -SMObject $WorkItem `
                                                -SMRelationship (Get-SCSMRelationshipClass -Id  "2da498be-0485-b2b2-d520-6ebd1698e61b") `
                                                -Direction Source
    return $activites 
} 

function Get-ActivityFromTag 
{ 
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
            [System.Object[]]$AllActivites,
        
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
            [string]$Tag
    ) 
    
    foreach ($item in $AllActivites) 
    { 
        if ($item.ActivityTag -eq $Tag) 
        { return $item; break } 
    } 
} 