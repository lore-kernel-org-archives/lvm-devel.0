From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:00:28 +0000
Subject: [PATCH 16/29] Test uuid for NULL
In-Reply-To: <fc1d0eaa750c2123a16edbb58b417889a5130141.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<fc1d0eaa750c2123a16edbb58b417889a5130141.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129210028.GD29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:20AM +0100, Zdenek Kabelac wrote:
> memcpy itself is declared as the function which doesn't take
> NULL as either src or dst parameter - let's be complaint.
 
Ack.

Alasdair


