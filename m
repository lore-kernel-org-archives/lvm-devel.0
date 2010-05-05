From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 May 2010 20:01:19 +0100
Subject: [RFC PATCH] Reduce noise about missing devices.
In-Reply-To: <87k4rsa8fd.fsf@twilight.int.mornfall.net.>
References: <87k4rsa8fd.fsf@twilight.int.mornfall.net.>
Message-ID: <20100505190119.GF27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 27, 2010 at 11:32:06PM +0200, Peter Rockai wrote:
> this is not intended to be directly applied, but more to start a
> discussion. One problem with our handling of missing devices is the huge
> amount of log noise each missing device produces. In a single run of
> lvconvert --repair, I get multiple screens of "read error" and "Couldn't
> find device with uuid"...
 
Well my first question before suppressing messages would be: Are all the
repeated accesses that generate the messages actually necessary?
Or are the messages just a symptom of other problems which should be
addressed instead?

Alasdair


