From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 20 Feb 2014 09:36:04 +0100
Subject: Deadlock on "systemctl daemon-reload" when using socket based lvmetad activation.
In-Reply-To: <20140220001412.41fe5ee5@opensuse.site>
References: <20140220001412.41fe5ee5@opensuse.site>
Message-ID: <5305BE74.6080101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/19/2014 09:14 PM, Andrey Borzenkov wrote:
> I tried to enable pure socket based activation of lvmetad (i.e. start
> only lvmetad.socket without lvmetad.service). This resulted in
> interesting deadlock. generator tries to connect to lvmetad if
> use_lvmetad=1 (implicitly as part of lvm_init()). During initial run on
> boot socket does not yet exist, so nothing bad happens. Now as long as
> there is no LVM configuration on a host and no LVM activity, lvmetad is
> also not started. If in this state "systemctl daemon-reload" is called
> (which is also implicitly done when enabling/disabling services)
> generators are run and LVM generator tries to contact lvmetad. Now
> socket *does* exist (it was created when lvmetad.socket was started)
> but systemd does not yet process incoming socket connections. So we
> have systemd waiting for generators to finish and generator waiting for
> systemd to accept socket connection request ...
> 
> Details are in https://bugzilla.novell.com/show_bug.cgi?id=862076#c44
> and following comment.
> 

Nice catch! Thanks for the report!

> It seems that full lvm_init() is rather overkill in this case;
> generators are supposed to be as lightweight as possible. Is there any
> way to only parse configuration without doing full initialization?
> 

The majority of lvm_init() code is about initializing the command context which also includes the configuration files. Thing with
configuration files is that they can be combined from several sources
to form the final configuration. It's probably possible to optimize
this a bit and factor out the configuration reading code, but at the
moment it's not a high priority since the gain of such optimization
is not very high. At the moment, it seems the generator is the only
specific user that *just* needs to read the configuration and do nothing
else.

> Always starting lvmetad really defeats the idea of socket activation
> (do not start process until needed) and does not fully eliminate the
> problem (consider lvmetad crashing in the wrong moment).
> 

I agree. I'm not even counting much that anybody uses lvmetad by
enabling the lvm2-lvmetad.service itself (though possible) - this was
primarily designed to be socket-based activated. The socket-based
activation should just work under all circumstances. I'll fix that...

Thanks.

-- 
Peter


