From: Konstantin Pavlov <thresh@altlinux.ru>
Date: Tue, 2 Mar 2010 12:38:18 +0300
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM daemons/dmeven ...
In-Reply-To: <20100202140918.25779.qmail@sourceware.org>
References: <20100202140918.25779.qmail@sourceware.org>
Message-ID: <20100302093818.GA10221@snowwhite.immo>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 02, 2010 at 02:09:18PM -0000, agk at sourceware.org wrote:
> --- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/01/21 22:15:46	1.13
> +++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/02/02 14:09:18	1.14
> @@ -36,7 +36,6 @@
>  
>  install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
>  	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
> -		$(libdir)/$<.$(LIB_VERSION)
> -	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
> +		$(libdir)/$<
>  
>  install: install_lvm2
> --- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/01/21 22:15:46	1.9
> +++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2010/02/02 14:09:18	1.10
> @@ -36,7 +36,6 @@
>  
>  install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
>  	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
> -		$(libdir)/$<.$(LIB_VERSION)
> -	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
> +		$(libdir)/$<
>  
>  install: install_lvm2

Keeping SONAMEs for those plugins leaves this commit pointless.

-- 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 198 bytes
Desc: Digital signature
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100302/cdde24d5/attachment.sig>
