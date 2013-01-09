From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 09 Jan 2013 00:25:58 -0600
Subject: [PATCH 2/3] lvm2app: Implementation of lv resize (v1)
In-Reply-To: <50EBF879.7080201@redhat.com>
References: <1357592534-14672-1-git-send-email-tasleson@redhat.com>
	<1357592534-14672-2-git-send-email-tasleson@redhat.com>
	<50EBF879.7080201@redhat.com>
Message-ID: <50ED0D76.7070702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/08/2013 04:44 AM, Zdenek Kabelac wrote:
> I'd prefer here to see separate patches which are
> just moving code and then new patches for changes
> of moved code.

New patch set submitted.  Some changes needed to occur to allow the code
to be moved.  This is broken down step by step.  Hopefully this will
make it easier to see what is going on.

> After moving code - try to add  '_' prefixes to internal 'static'
> functions.

OK

> we have macro shortcut - return_0;

Using it now.

> goto_out

Using this too...

> {} around single commands unneeded

OK

Thanks,
Tony


