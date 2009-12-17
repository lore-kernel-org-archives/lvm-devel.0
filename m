From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 17 Dec 2009 10:39:46 +0100
Subject: Re: LVM2 lib/activate/dev_manager.c lib/cache/lvmc ...
In-Reply-To: <20091216192214.22164.qmail@sourceware.org>
References: <20091216192214.22164.qmail@sourceware.org>
Message-ID: <4B29FC62.4000003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 16.12.2009 20:22, mornfall at sourceware.org napsal(a):
> Modified files:
> 	lib/activate   : dev_manager.c 
> 	lib/cache      : lvmcache.c 
> 	lib/format_text: export.c text_label.c 
> 	lib/locking    : locking.c 
> 	lib/log        : log.c log.h 
> 	lib/metadata   : metadata.c 
> 	lib/mm         : memlock.c 
> 	lib/striped    : striped.c 
> 	tools          : lvm.c lvmcmdline.c 
> 
> Log message:
> 	#define an INTERNAL_ERROR macro and use it throughout LVM.
> 
> > -		log_error("Internal error: Nested locking attempted on VG %s.",
> +		log_error(INTERNAL_ERROR "Nested locking attempted on VG %s.",
>  			  vgname);

Maybe we could introduce new macro


log_IERROR() & log_IDEBUG() to prepend string INTERNAL_ERROR and make the line
shorter and more readable ?


And check for abort() on internal error could be used only in case of these
macros. (thus simplify  print_log() function)

Also - it looks like when _log_suppress == 2 and abort_on_internal_errors is
set - the abort() is skipped - is this bug or features ?

Zdenek


