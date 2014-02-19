From: Andrey Borzenkov <arvidjaar@gmail.com>
Date: Thu, 20 Feb 2014 00:14:12 +0400
Subject: Deadlock on "systemctl daemon-reload" when using socket based lvmetad activation.
Message-ID: <20140220001412.41fe5ee5@opensuse.site>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I tried to enable pure socket based activation of lvmetad (i.e. start
only lvmetad.socket without lvmetad.service). This resulted in
interesting deadlock. generator tries to connect to lvmetad if
use_lvmetad=1 (implicitly as part of lvm_init()). During initial run on
boot socket does not yet exist, so nothing bad happens. Now as long as
there is no LVM configuration on a host and no LVM activity, lvmetad is
also not started. If in this state "systemctl daemon-reload" is called
(which is also implicitly done when enabling/disabling services)
generators are run and LVM generator tries to contact lvmetad. Now
socket *does* exist (it was created when lvmetad.socket was started)
but systemd does not yet process incoming socket connections. So we
have systemd waiting for generators to finish and generator waiting for
systemd to accept socket connection request ...

Details are in https://bugzilla.novell.com/show_bug.cgi?id=862076#c44
and following comment.

It seems that full lvm_init() is rather overkill in this case;
generators are supposed to be as lightweight as possible. Is there any
way to only parse configuration without doing full initialization?

Always starting lvmetad really defeats the idea of socket activation
(do not start process until needed) and does not fully eliminate the
problem (consider lvmetad crashing in the wrong moment).


