From: Petr Rockai <prockai@redhat.com>
Date: Tue, 03 Feb 2009 00:28:40 +0100
Subject: [PATCH 05/13] Add lvm_vg_open().
In-Reply-To: <1233607809-1087-6-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 2 Feb 2009 15:50:01 -0500")
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
Message-ID: <87hc3c7713.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> RFC - lvm_vg_open().  The new vg_read() function is a step in the right
> direction but still contains a lot of new options / flags that will
> be new to people and we can hopefully simplify.  lvm_vg_open() was
> modelled after 'open' which gives us a potential model that others are
> familiar with.  Can we use the modes and flags of 'open' in a similar way
> or do we need to introduce new flags/concepts to people?  For example,
> can we use a some of the open flags such as O_CREAT and O_EXCL to
> implement READ_CHECK_EXISTENCE?
I am currently leaning towards using a completely separate entrypoint for the
existence check function. It might have been a one bit too much flag abuse,
that one. Count it as laziness on my part.

I am not entirely convinced about the open metaphor. For one, the locking
semantics don't go well with that -- files are racy by default and need to be
quite carefully locked to prevent awful things from happening. We don't want to
make that implication. Maybe working a little on the vg_read interface would
make it acceptable to a newcomer, without causing too much confusion?

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


