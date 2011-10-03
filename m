From: Lukas Czerner <lczerner@redhat.com>
Date: Mon, 3 Oct 2011 18:13:39 +0200 (CEST)
Subject: [PATCH v3 02/18] fsadm: Make all internal math in kilobytes
In-Reply-To: <4E81EEC6.1010904@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-3-git-send-email-lczerner@redhat.com>
	<4E81EEC6.1010904@redhat.com>
Message-ID: <alpine.LFD.2.00.1110031803420.4447@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 27 Sep 2011, Zdenek Kabelac wrote:

> Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> > We should make all math in fsadm to count with kilobytes (if possible)
> > because it will bypass the problem of having too big numbers. Also the
> > smaller granularity might have troubles with 512B alignment.
> 
> 
> I don't like this one -  if you have problems with big numbers - bugreport
> bash. You are probably covering up different bug here.

I am not sure you do not "like" this one, it does not seem like a real
reason, could you be more specific ? This patch just forces internal
math to be done in kilobytes, since there is no real reason to do it in
bytes.

It has no implications for the user interface.


Also, please when you reply to my patches, could you cc me as well ?
This is not the only list I am sending patches to so I can not just
check all lists for replies.

Thanks!
-Lukas

> 
> 
> Zdenek
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


