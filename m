From: Gang He <ghe@suse.com>
Date: Tue, 09 Apr 2019 04:14:09 -0600
Subject: lvm snapshot creation ends with the error message
Message-ID: <5CAC7071020000F90005E796@prv1-mh.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Guys,

Our user complained a confused error message when create a LV snapshot successfully.
e.g. 
lvcreate --snapshot "/dev/$vgroup/$volume" --name "$snapvol" -l '80%FREE' 
returns the following:
Taking snapshot mongo_db-snap
  device-mapper: remove ioctl on (254:2) failed: Device or resource busy  <<== here, why we need to print this error message? since we can retry a few time before failure
  Logical volume "mongo_db-snap" created.

The related code is in libdm-iface.c file under libdm/ioctl.

1873                 else {
1874                         if (_log_suppress || dmt->ioctl_errno == EINTR)
1875                                 log_verbose("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
1876                                             "failed: %s",
1877                                             _cmd_data_v4[dmt->type].name,
1878                                             dmi->name, dmi->uuid,
1879                                             dmt->major > 0 ? "(" : "",
1880                                             dmt->major > 0 ? dmt->major : 0,
1881                                             dmt->major > 0 ? ":" : "",
1882                                             dmt->minor > 0 ? dmt->minor : 0,
1883                                             dmt->major > 0 && dmt->minor == 0 ? "0" : "",
1884                                             dmt->major > 0 ? ")" : "",
1885                                             strerror(dmt->ioctl_errno));
1886                         else
1887                                 log_error("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
1888                                           "failed: %s",
1889                                           _cmd_data_v4[dmt->type].name,
1890                                           dmi->name, dmi->uuid,
1891                                           dmt->major > 0 ? "(" : "",
1892                                           dmt->major > 0 ? dmt->major : 0,
1893                                           dmt->major > 0 ? ":" : "",
1894                                           dmt->minor > 0 ? dmt->minor : 0,
1895                                           dmt->major > 0 && dmt->minor == 0 ? "0" : "",
1896                                           dmt->major > 0 ? ")" : "",
1897                                           strerror(dmt->ioctl_errno));
1898


Thanks
Gang




