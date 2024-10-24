Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D04A17623F
	for <lvm-devel@lists.linux.dev>; Thu, 24 Oct 2024 19:40:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1729798849; cv=none; b=O4mGHdDvFvyIcRtRzMSkGWlF5DcpDlN+R4w9x1/UwFJM6jzC9dblDrTJEa20xRp+z7CPRX0Ay6ObJa0pSEtNQ6YPVrOtXHjk+itmAy1PmSzoBIjcB2zTRO+Rjpq+lPiYzdFthfh/04sVQ3tSpgQjjx+kgVhDqUUOITR4BoNQoXs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1729798849; c=relaxed/simple;
	bh=41dyo7N0pnlwUlNOV+aMB5SUXYSJnA+0e8U/NxnRyxQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=LlaAcLP+/MWudjEpUwVSb4K1rfjc4IDRJn9AX2PW6hIzCBkCCdMJ8DWYsEnzKUf1VtTYr3cgSAbXFutxR4RyR0CHTZb1y4vD6a/clzlrj2W6uPWrSvpTNBeo13yywkXgRO5+VwFn+fka0FwZJ/chzSBU1muCzrB6k8BmRhs3+54=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=J1rwlUOo; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="J1rwlUOo"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1729798846;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=41dyo7N0pnlwUlNOV+aMB5SUXYSJnA+0e8U/NxnRyxQ=;
	b=J1rwlUOo807gR22H27qsCRRG43s9cBsLCtA3vQtTYqDIxUOxqx9rUc4hq2zEEFARg3Z6Wo
	EARTteZgquSa9AHI+BWuTR6N45wi14jNJnLSmdx1f5Q49EVGV9ZLinzfnHOdJ2HeAzSo+L
	J8wX3CY6AT1IDuf3wWHIoFQ91Y43y8Y=
Received: from mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-19-wq_nQDLkOSeqnZRKye_l9Q-1; Thu,
 24 Oct 2024 15:40:44 -0400
X-MC-Unique: wq_nQDLkOSeqnZRKye_l9Q-1
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 549421955EA7;
	Thu, 24 Oct 2024 19:40:42 +0000 (UTC)
Received: from [10.45.224.114] (unknown [10.45.224.114])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id DD36A1956056;
	Thu, 24 Oct 2024 19:40:38 +0000 (UTC)
Message-ID: <f19f9d14-3ff8-42ba-9fc4-3e2a834bba66@redhat.com>
Date: Thu, 24 Oct 2024 21:40:37 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] cleanup: rename invalid function to real function in
 annotation
To: long.yunjian@zte.com.cn, lvm-devel@lists.linux.dev
Cc: xue.zhihong@zte.com.cn, cai.qu@zte.com.cn, jiang.yong5@zte.com.cn,
 xu.lifeng1@zte.com.cn
References: <20241016101627552OQp0AQIZhpja0akhFT2Da@zte.com.cn>
From: Zdenek Kabelac <zkabelac@redhat.com>
In-Reply-To: <20241016101627552OQp0AQIZhpja0akhFT2Da@zte.com.cn>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Language: en-US, cs
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 16. 10. 24 v 4:16 long.yunjian@zte.com.cn napsal(a):
> There are no fuction named print_common_options_cmd()
> and print_common_options_lvm(). So, rename them to the
> real function named print_usage_common_cmd() and
> print_usage_common_lvm().


Hi


Thanks for noticing. Patch is now pushed upstream.

Regards

Zdenek


