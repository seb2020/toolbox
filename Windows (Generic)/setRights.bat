@IF EXIST "C:\Program Files\OpenVPN" (
  icacls "C:\Program Files\OpenVPN" /inheritance:d
  icacls "C:\Program Files\OpenVPN" /GRANT "SYSTEM:(CI)(OI)(F)"
  icacls "C:\Program Files\OpenVPN" /GRANT "Administrateurs:(CI)(OI)(F)"
  icacls "C:\Program Files\OpenVPN" /GRANT "Utilisateurs:(CI)(OI)(F)"
)
pause