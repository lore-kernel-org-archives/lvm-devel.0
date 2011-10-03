From: Lukas Czerner <lczerner@redhat.com>
Date: Mon, 3 Oct 2011 18:39:54 +0200 (CEST)
Subject: [PATCH v3 13/18] fsadm: remove -y (YES) option
In-Reply-To: <4E81EDE3.5020406@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-14-git-send-email-lczerner@redhat.com>
	<4E81EDE3.5020406@redhat.com>
Message-ID: <alpine.LFD.2.00.1110031821120.4447@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 27 Sep 2011, Zdenek Kabelac wrote:

> Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> > There is some confusion in using -y (YES) and -f (FORCE) options in
> > fsadm. In some cases we are asked for yes/no question which can be
> > override by -f option, but not by -y option. Usually most of the questions
> > tools ask for are yes/no and it can be overridden by forcing it with -f
> > (e.g. fsck.(extN|xfs), lvm and others...) so it make sense to get rid of
> > -y option and use only -f instead.
> > 
> > Also I do not think it is wise to use -y option in fsck.extN since
> > people using fsadm would probably not know how it works, so we should
> > NOT provide them with that option, but rather let them use "real" fsck
> > instead (and let them read man page if needed). Also running fsck with
> > -y when you have corrupted file system is probably not a good idea from
> > multiple reasons. This is also fixed by this commit.
> > 
> > This commit removes '-y' option and use '-f' instead. With exception of
> > fsck.
> > 
> 
> NACK
> 
> -f  and  -y  are different.
> 
> While  fsck will proceed with -f  on mounted file system (leading to certain
> damage) -y  option will stop here and just answer -y  to  question about umount.

I am not saying that -f should be used instead of -y.

That is why having both options for the fsadm does not make sense,
because it is not just fsck which fsadm is using internally. Force means
force, we are trying to simplify things here not map every argument of
every tool into fsadm.

When user force things, he should know what is he doing, since he really
is using "force" :). -f option is quite generic and most of the tools
does have it, however -y options is specific, that is why fsadm does not
have -n option, or even -p option.

Generally I am in favour of changing check command to only check for
file system consistency and if problems are found report to the user
that he should run proper fsck by itself, since it is a bit delicate
situation and the user should really know what is he doing if he does
not want to lose data.

Finally I think that having both '-f' and '-y' option which are really
inconsistent among the tools does not make sense.

Thanks!
-Lukas

> 
> And also you would change command line syntax and change the behavior of
> already written scripts.
> 
> Zdenek
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 

-- 


