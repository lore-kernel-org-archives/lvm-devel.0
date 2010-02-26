From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 26 Feb 2010 13:48:17 +0100
Subject: New clvmd init script (second take)
Message-ID: <4B87C311.5010807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi guys,

Started from https://bugzilla.redhat.com/show_bug.cgi?id=533247

- fix whitespaces all over (tabs/spaces)
- increase timeout to 30 secs (on Chrissie request)
- source both cluster and clvmd for options (like all the other cluster
  init scripts)
- add clustered_vgs and _lvs commodity fns
- move rh_status* fns at the top, so they can be reused
- heavily cleanup start and stop fns from redundant code and unnecessary
  loops
- improve output from different operations
- make the init script lsb compliant
- don?t force kill of the daemon, send only a TERM signal and then wait
for it to exit

Thanks
Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd_init_red_hat.in
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100226/8dfb5f54/attachment.ksh>
