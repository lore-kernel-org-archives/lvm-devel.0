Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 782E342AA8
	for <lvm-devel@lists.linux.dev>; Tue, 13 Aug 2024 11:35:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1723548931; cv=none; b=rUCQczUoKPpqzP7uDmAEQK3pEdVpK4iaXTvCYAKQJkJem8BCRyGjrVrP8OcevbVPMz4/s46G4FrXaHSLbPCORtI0zhcJyuEeTSRTTS1ZfsLVpsOYizT/iv6zu0ghX6FOzovhxN6gm7Dkp8D5/lag2bZ3KJ5lOYXHyKzyEalVCNw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1723548931; c=relaxed/simple;
	bh=hoRVU9SotxXgdqqDFSEBkMtlSeq6+j+Rx4xmxxvVztE=;
	h=Date:From:To:cc:Subject:Message-ID:MIME-Version:Content-Type; b=qUldW5EGFoNaTdkJRTjbT1OKyc0t6RHt4ZuhMadeUGP60tG4YGtNq12anLusWIj6oNtlk9Ro8L8XoA+ky+zT2irU6XQECPYpQku743FN158A3FCmWHi+BQALLND/Gt1pVbXwJncIp+T2FK2X+aaGgTaP+1QN48Bk9mZM5Bhguyg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Wh8Pwu9O; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Wh8Pwu9O"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1723548928;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type;
	bh=ScTqXTBz1RdAx1iyxUIH3cMxf89RXs3vFmrbwZEQJk4=;
	b=Wh8Pwu9Og5jQtmCxpP6OMjMG48fZA8IIy/Lzbh/JVXJ7qHf1wIxm1Ro04EuWcW6hpdjaOV
	F2l91LhcG2Nnp0rkMC5PbmyLbDPM88ZKO2xFHdsddXFHTSdcVtRvdmvZwafdinTMkmKo5C
	ktuGjhe9Fs+/n3XobYpsRxOcs1huZf8=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-286-J5MCLCslMQ-SjU1o46eGWw-1; Tue,
 13 Aug 2024 07:35:25 -0400
X-MC-Unique: J5MCLCslMQ-SjU1o46eGWw-1
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7DAA119560B1
	for <lvm-devel@lists.linux.dev>; Tue, 13 Aug 2024 11:35:24 +0000 (UTC)
Received: from file1-rdu.file-001.prod.rdu2.dc.redhat.com (unknown [10.11.5.21])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 1F8D4300019C;
	Tue, 13 Aug 2024 11:35:24 +0000 (UTC)
Received: by file1-rdu.file-001.prod.rdu2.dc.redhat.com (Postfix, from userid 12668)
	id EB95B30C1C18; Tue, 13 Aug 2024 11:35:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by file1-rdu.file-001.prod.rdu2.dc.redhat.com (Postfix) with ESMTP id E88CF3FB48;
	Tue, 13 Aug 2024 13:35:22 +0200 (CEST)
Date: Tue, 13 Aug 2024 13:35:22 +0200 (CEST)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Zdenek Kabelac <zkabelac@redhat.com>
cc: lvm-devel@lists.linux.dev
Subject: [PATCH] fix comparison warning on 32-bit architectures.
Message-ID: <6628f795-dec7-4dfe-17e2-a6fb96ba3042@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=US-ASCII

Hi

This patch fixes a warning about comparison between signed and unsigned
integer.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 test/lib/brick-shelltest.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: lvm2/test/lib/brick-shelltest.h
===================================================================
--- lvm2.orig/test/lib/brick-shelltest.h	2024-08-13 13:31:34.000000000 +0200
+++ lvm2/test/lib/brick-shelltest.h	2024-08-13 13:32:24.000000000 +0200
@@ -713,7 +713,8 @@ struct KMsg : Source {
     void transform( char *buf, ssize_t *sz ) {
         char newbuf[ buffer_size ];
         struct tm time_info;
-        unsigned level, num, pos;
+        int pos;
+        unsigned level, num;
         unsigned long t;
         time_t tt;
         size_t len;

