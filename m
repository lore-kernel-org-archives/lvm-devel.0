From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 04 Feb 2010 15:54:07 +0100
Subject: New clvmd init script
Message-ID: <4B6ADF8F.9040203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi guys,

Started from https://bugzilla.redhat.com/show_bug.cgi?id=533247

- fix whitespaces all over (tabs/spaces)
- use secure path
- remove hardcoding of paths for tools
- increase timeout to 30 secs (on Chrissie request)
- source both cluster and clvmd for options (like all the other cluster
init scripts)
- add clustered_vgs and _lvs commodity fns
- move rh_status* fns at the top, so they can be reused
- heavily cleanup start and stop fns from redundant code and unnecessary
loops
- drop wait_for_finish. According to docs killproc will send first
specified signals and then SIGKILL and do the way for us.
- improve output from status
- make the init script lsb compliant

Please review and let me know if we need to add more changes.

Both Chrissie and I have tested this new version.

Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd_init.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100204/70cabc5c/attachment.ksh>
