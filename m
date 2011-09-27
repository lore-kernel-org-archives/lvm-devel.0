From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Sep 2011 17:38:11 +0200
Subject: [PATCH v3 13/18] fsadm: remove -y (YES) option
In-Reply-To: <1317130971-24173-14-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-14-git-send-email-lczerner@redhat.com>
Message-ID: <4E81EDE3.5020406@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> There is some confusion in using -y (YES) and -f (FORCE) options in
> fsadm. In some cases we are asked for yes/no question which can be
> override by -f option, but not by -y option. Usually most of the questions
> tools ask for are yes/no and it can be overridden by forcing it with -f
> (e.g. fsck.(extN|xfs), lvm and others...) so it make sense to get rid of
> -y option and use only -f instead.
> 
> Also I do not think it is wise to use -y option in fsck.extN since
> people using fsadm would probably not know how it works, so we should
> NOT provide them with that option, but rather let them use "real" fsck
> instead (and let them read man page if needed). Also running fsck with
> -y when you have corrupted file system is probably not a good idea from
> multiple reasons. This is also fixed by this commit.
> 
> This commit removes '-y' option and use '-f' instead. With exception of
> fsck.
> 

NACK

-f  and  -y  are different.

While  fsck will proceed with -f  on mounted file system (leading to certain
damage) -y  option will stop here and just answer -y  to  question about umount.

And also you would change command line syntax and change the behavior of
already written scripts.

Zdenek


