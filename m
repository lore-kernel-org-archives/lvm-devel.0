From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:43:48 +0000
Subject: [PATCH 11/29] Add stack trace for error path
In-Reply-To: <0c942670df4d53c9c6581513a8a7c0ef10eda778.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<0c942670df4d53c9c6581513a8a7c0ef10eda778.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129204348.GZ29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:15AM +0100, Zdenek Kabelac wrote:
> If dm_task_set_cookie fail - print stack trace, but keep going on.

Ack.
(Function can't currently fail.)

Alasdair


