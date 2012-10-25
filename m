From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 25 Oct 2012 18:24:25 -0500
Subject: liblvm and device creation
Message-ID: <5089CA29.2040103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When running within the confines of the test directory on a system which
does not lvm installed, udev does not create the device files.  The lvm
command line utility falls back and creates them.  When using the liblvm
library this functionality is absent.

Is there any reason they shouldn't behave the same?

Thanks,
Tony


