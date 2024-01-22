# Translate-Sid
Connects to AD and translates SID via Get-AD-Object, then performs more lookups depending on user or group object class

---

**Parameters**

_sid_

The sid of the AD-Object that you are looking up

---

**Examples**

```powershell
Translate-Sid -sid S-1-5-21-3326329815-2907898539-2989652515-223100
```
