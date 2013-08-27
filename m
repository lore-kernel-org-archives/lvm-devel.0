From: Oliver Rath <rath@mglug.de>
Date: Tue, 27 Aug 2013 18:32:38 +0200
Subject: lvm-git doesnt set links
Message-ID: <521CD4A6.1050802@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

the actual git-snapshot from today seems a bit broken:

If i generate a snapshot from an existing thinpool-device, the device is
created (visible by lvdisplay), but no softlink will be created, nor in
/dev/myvg/ neither in /dev/mapper.

Same config like in last mail today.

What happened?

Tfh
OIliver


