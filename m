From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 19 Aug 2010 15:33:27 +0100
Subject: [PATCH 02/11] Add 'writeable' field to columns.h
In-Reply-To: <1282139522-31240-3-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
	<1282139522-31240-3-git-send-email-dwysocha@redhat.com>
Message-ID: <20100819143327.GQ11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 18, 2010 at 09:51:53AM -0400, Dave Wysochanski wrote:
> + * 10. Writeable field.  If the field is writeable, a 'set' function must be
> + * defined.

Let's do this like we did in args.h with a flags field, to reduce the churn
if we decide to add more properties.

10. Flags.
    FIELD_MODIFIABLE.  A '_set' function exists to change the field's value.
                       The function name is derived in a similar way to item 7 above.
    
Alasdair


