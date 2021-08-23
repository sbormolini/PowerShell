enum Mode {
    Inactive = 0
    Active = 1
    Maintenance = 2 
}

class Device 
{
    [guid] hidden $Id
    [string] $Name
    [Mode] hidden $Mode

    Device ($Name) 
    {
        $this.Id = [guid]::NewGuid()
        $this.Name = $Name
    }

    [void] SetName($NewName)
    {
        $this.Name = $NewName
    }

    [void] SetMode([Mode]$Mode)
    {
        $this.Mode = $Mode
    }

    [Mode] GetMode()
    {
        return $this.Mode
    }
}