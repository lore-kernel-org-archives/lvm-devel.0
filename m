Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A1BB219317
	for <lvm-devel@lists.linux.dev>; Mon, 17 Mar 2025 07:51:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1742197914; cv=none; b=OhyKbhA7u2ghPFPgFrWbdIdfcAz1FcvgZpL3I82w2jotg+g5evrnZlrK9WE9qcWYrH4OcAvQlDzp2OmLzVevxwR0lvf6H86b1ca2AceBUWUXXoIxWg5M/9iSlI7IBIEuT0LxheIz8rmQf8PxaiSWpGfzI+CY5BCH3Xfv35t6UgI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1742197914; c=relaxed/simple;
	bh=P/Ye8q5gTB+++EM+w6kMDiZoYxlJQJfV36Ec1IE3DJc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:content-type; b=GcBAenB85+neoPYbUWDdJNu/XGeIShlQ063ZrDkLEhGMAKZ6Udcvs07UN+fVYiHzDR+qdIGCgNdOIFXmqOiBWLxo5mL9zwV6Fd9snjlh6fFYuK1Iym/PcNRO8Z9I8NkFdCfLbgD75YbYSZs92MFT4/OrocciItTeaPg6Wz5f49Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=IGm6CGNM; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="IGm6CGNM"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1742197912;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kYd69j/pPnA66YvXIfbRvYQXZOEZkIkJ0vgMgkw6JY8=;
	b=IGm6CGNMBlARwQxcx/Oke9FSgAw5PXYPOlOFkQncglm+o6Haj+fXdLoW17+6YfkcMvKprl
	U2qX3DK7hx8XOr6kUSTnQSilrsyArwExXedkg1eDpJ3fLqej4eSHsjZyaacWLVZpJgDsFu
	pkPNuUukali4fbz19Bn/GSp5ibtuU6Y=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-452-pb-Ur266MzGAYyhfH9UIHg-1; Mon,
 17 Mar 2025 03:51:50 -0400
X-MC-Unique: pb-Ur266MzGAYyhfH9UIHg-1
X-Mimecast-MFC-AGG-ID: pb-Ur266MzGAYyhfH9UIHg_1742197909
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A8F1019560B3
	for <lvm-devel@lists.linux.dev>; Mon, 17 Mar 2025 07:51:49 +0000 (UTC)
Received: from thinkpad.redhat.com (unknown [10.64.240.119])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 74EFF1955DCD;
	Mon, 17 Mar 2025 07:51:46 +0000 (UTC)
From: Ming-Hung Tsai <mtsai@redhat.com>
To: lvm-devel@lists.linux.dev
Cc: zkabelac@redhat.com,
	Ming-Hung Tsai <mtsai@redhat.com>
Subject: [PATCH 2/2] cache: fix integer conversion error in parsing cache_pool_max_chunks
Date: Mon, 17 Mar 2025 15:51:25 +0800
Message-ID: <20250317075125.840941-2-mtsai@redhat.com>
In-Reply-To: <20250317075125.840941-1-mtsai@redhat.com>
References: <20250317075125.840941-1-mtsai@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: oYBCPqLH0SD9mLJhmd1GytNJzkYHc2pXhY4RLld6QjM_1742197909
X-Mimecast-Originator: redhat.com
Content-Transfer-Encoding: 8bit
content-type: text/plain; charset="US-ASCII"; x-default=true

The allocation/cache_pool_max_chunks config is read as an int32_t,
then converted to uint64_t. If the value in lvm.conf exceeds INT32_MAX,
conversion to uint64_t results in truncation followed by sign extension,
causing the original unsigned representation to be lost. For example, a
config value of 6442450944 is converted to 18446744071562067968.

This fix preserves the original u64 value from the parser. Further
adjustments should be applied to fit dm-cache's metadata limits.

Signed-off-by: Ming-Hung Tsai <mtsai@redhat.com>
---
 lib/config/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 9df9c925c152..fc7d16279f31 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -2555,7 +2555,7 @@ uint64_t get_default_allocation_cache_pool_max_chunks_CFG(struct cmd_context *cm
 	 *       newer targets may scale better.
 	 */
 	uint64_t default_max_chunks = DEFAULT_CACHE_POOL_MAX_CHUNKS;
-	uint64_t max_chunks = find_config_tree_int(cmd, allocation_cache_pool_max_chunks_CFG, profile);
+	uint64_t max_chunks = find_config_tree_int64(cmd, allocation_cache_pool_max_chunks_CFG, profile);
 
 	if (!max_chunks)
 		max_chunks = default_max_chunks;
-- 
2.47.0

