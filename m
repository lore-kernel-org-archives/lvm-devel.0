From: Petr Rockai <prockai@redhat.com>
Date: Tue, 12 Oct 2010 17:52:22 +0200
Subject: [PATCH 02/14] Refactor and add code for (lv) 'lv_path' get function.
In-Reply-To: <1286893799.15299.13.camel@f12-work> (Dave Wysochanski's message
	of "Tue, 12 Oct 2010 10:29:59 -0400")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-3-git-send-email-dwysocha@redhat.com>
	<87tyks38l1.fsf@twilight.int.mornfall.net.>
	<1286893799.15299.13.camel@f12-work>
Message-ID: <87iq17v26h.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

>> Should the above dm_pool_zalloc/dm_snprintf go into some
>> dm_pool_asprintf, in fact? That would also remove that "len"
>> computation and make this function completely trivial. We already
>> have dm_asprintf (which uses dm_malloc). You could probably
>> parametrise dm_asprintf with the strdup function into
>> dm_generic_asprintf and have both dm_asprintf and dm_pool_asprintf
>> implemented in terms of that.

> If it's ok with you, I may defer these to a couple cleanup patches.
> They are good suggestions but I'm mostly focused on straight moving
> and refactoring for this patch set.

Sure, no problem. That can be done later. The patch is, logic-wise, in
order, as far as I can tell. The suggestions are quite optional, and of
course there's always a tradeoff. Ok to check in, I'll look at factoring
in dm_pool_asprintf later.

Yours,
   Petr.


