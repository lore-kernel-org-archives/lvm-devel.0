From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 20 Mar 2011 14:09:13 +0100
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <20110320020053.24940.qmail@sourceware.org>
References: <20110320020053.24940.qmail@sourceware.org>
Message-ID: <4D85FC79.6050709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.3.2011 03:00, agk at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	agk at sourceware.org	2011-03-20 02:00:52
> 
> Modified files:
> 	libdm/ioctl    : libdm-iface.c 
> 
> Log message:
> 	Fix last checkin - added error message text wrong.
> 
> Patches:

>  
> -	if (!_dm_compat) {
> -		log_error("Support for older device-mapped version is disabled.");
> -		goto bad;
> -	}
> +	if (!_dm_compat)
> +		goto_bad;

My patch was only fixing error reporting logic.

Now it's reports 'stack' trace before the actual report.

AFAIK your own rule is - to always report error first and then report 'stack'
traces upward.

Did I get this rule wrong - are there some exceptions?

Zdenek


