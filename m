From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:09:33 +0000
Subject: [PATCH 09/29] Remove check for lv is NULL
In-Reply-To: <23421ea755e11ff7379ced9a1ea40b319b797fe7.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<23421ea755e11ff7379ced9a1ea40b319b797fe7.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129200933.GT29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:13AM +0100, Zdenek Kabelac wrote:
> 'lv' is deferenced in the begining of the function so any check
> later is not helpful.
 
Caller always supplies it these days, ack.

Alasdair


