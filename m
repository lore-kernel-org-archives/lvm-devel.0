From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Jul 2012 23:08:27 +0100
Subject: [RFC PATCH 1/3] lvm-wrappers: implement wrappers to get min/max u64 values
In-Reply-To: <1342473519-2853-2-git-send-email-dongsu.park@profitbricks.com>
References: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
	<1342473519-2853-2-git-send-email-dongsu.park@profitbricks.com>
Message-ID: <20120716220827.GA2641@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 16, 2012 at 11:18:37PM +0200, dongsu.park at profitbricks.com wrote:
> Simple wrappers to get minimum or maximum values from the two uint64 values.

We already use MAX/MIN for this from one of the /usr/include headers.

Alasdair


