Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6875D19AD8D
	for <lvm-devel@lists.linux.dev>; Tue,  1 Oct 2024 22:46:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1727822807; cv=none; b=Efjoxb/3nx7gVdBKeVQNAnb5QdrVv5QLOG9HprVNG/EMH9wWgARc/4fgZdlPEvEBjr2hXfA8pSepBIfZnITAIZ/IvHd2nOpucM03YrY7dhJ+ea0HLZp0mJIjVUD4W2hkg3buF5y6yWJvq3rb8c5QyqlCys0yL0gX7RQg3+BL2No=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1727822807; c=relaxed/simple;
	bh=sw4k+DmpStVrdpAvW6BvF+r0doTAI1jIjkl07MZbHok=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=N/eMo7qIlCc+yv5tZIfXv4sW7r84qvt6/hhxpolt5ixlqDrnPOtNYmq093YMd3sqy7EZ9vpWIs1pomaWQU3s3rzjLyA0LFhajZ3xpA4tvNTXO9HWgKCQO3/sIi9WPmxXWzQyAaHkV3hEDFY7eIfT6FDb1EYG7s4CxwLc/1+Y+u4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=HHubkDaq; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="HHubkDaq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1727822804;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=Furj7MNHJ/GcmNyDe5XLQNaxsx7Hq8WzpsoEMmBrpJU=;
	b=HHubkDaqvxjKoKmBsmx+OrjZXeu/PN204OZ4wOlAQmDrEWQyuIESS16alZHT8YYUATmpbp
	Wup7zKpMEcxb5NY15MlrHkbvkoTWNSQYhC+VWfOx9K6MOyq8OVgqKU2Njye6jqVqdH1xZ7
	i2kzue6HVqwskD3qV7tnDPWBrYJmNzk=
Received: from mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-538-UuJ_PWGiNL2--1zzKgHeCg-1; Tue,
 01 Oct 2024 18:46:42 -0400
X-MC-Unique: UuJ_PWGiNL2--1zzKgHeCg-1
Received: from mx-prod-int-02.mail-002.prod.us-west-2.aws.redhat.com (unknown [10.30.177.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5F80E1944D22
	for <lvm-devel@lists.linux.dev>; Tue,  1 Oct 2024 22:46:41 +0000 (UTC)
Received: from bmarzins-01.fast.eng.rdu2.dc.redhat.com (unknown [10.6.23.12])
	by mx-prod-int-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E360C191BD01;
	Tue,  1 Oct 2024 22:46:40 +0000 (UTC)
Received: from bmarzins-01.fast.eng.rdu2.dc.redhat.com (localhost [127.0.0.1])
	by bmarzins-01.fast.eng.rdu2.dc.redhat.com (8.17.2/8.17.1) with ESMTPS id 491MkdcA2148323
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 1 Oct 2024 18:46:39 -0400
Received: (from bmarzins@localhost)
	by bmarzins-01.fast.eng.rdu2.dc.redhat.com (8.17.2/8.17.2/Submit) id 491Mkdm22148322;
	Tue, 1 Oct 2024 18:46:39 -0400
From: Benjamin Marzinski <bmarzins@redhat.com>
To: lvm-devel@lists.linux.dev
Cc: Zdenek Kabelac <zkabelac@redhat.com>,
        Heinz Mauelshagen <heinzm@redhat.com>
Subject: [PATCH] tests: wait for size to be updated in lvconvert-raid-reshape-size.sh
Date: Tue,  1 Oct 2024 18:46:39 -0400
Message-ID: <20241001224639.2148314-1-bmarzins@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset="US-ASCII"; x-default=true

lvconvert-raid-reshape-size was occassionally failing because it was
checking the size before it got updated.

Signed-off-by: Benjamin Marzinski <bmarzins@redhat.com>
---
 test/shell/lvconvert-raid-reshape-size.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/lvconvert-raid-reshape-size.sh b/test/shell/lvconvert-raid-reshape-size.sh
index ea367da18..2758eca71 100644
--- a/test/shell/lvconvert-raid-reshape-size.sh
+++ b/test/shell/lvconvert-raid-reshape-size.sh
@@ -158,6 +158,7 @@ function _reshape_layout
 	if [ $wait_for_reshape -eq 1 ]
 	then
 		aux wait_for_sync $vg $lv $ignore_a_chars
+		sleep 1
 		fsck -fn "$DM_DEV_DIR/$vg/$lv"
 	fi
 }
@@ -289,6 +290,7 @@ function _test
 	# Wait for sync to finish to check frow extended LV size
 	aux wait_for_sync $vg $lv 0
 
+	sleep 1
 	[ $(_check_size $vg $lv $(($data_stripes + 1))) -eq 0 ] || die "LV size should be grown"
 	fsck -fy "$DM_DEV_DIR/$vg/$lv"
 	udevadm settle
-- 
2.43.5

