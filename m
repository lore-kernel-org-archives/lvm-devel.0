From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 12:45:32 +0000
Subject: [PATCH] New public functions lvm2_reload_config, lvm2_set_config_option and lvm2_reset_config_option.
In-Reply-To: <49424CBE.6020204@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
	<1229013822-10809-3-git-send-email-twoerner@redhat.com>
	<1229013822-10809-4-git-send-email-twoerner@redhat.com>
	<1229032195.20795.34.camel@localhost.localdomain>
	<49424CBE.6020204@redhat.com>
Message-ID: <20081212124532.GZ24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Dec 12, 2008 at 12:36:30PM +0100, Thomas Woerner wrote:
> Ok, I will add tools/tools.h, tools/toollib.h, tools/commands.h and 
> tools/args.h to include/.smylinks. Then it is possible to use #include 
> "tools.h".
 
You can't use *anything* from the tools directory in the library!
That would be like linking the library against anaconda or
other client code!
Where you need any functions in there you need to move them first 
into the lib directory behind a proper interface.

Alasdair
-- 
agk at redhat.com


