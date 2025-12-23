Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com [209.85.167.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 936E734AAEA
	for <lvm-devel@lists.linux.dev>; Tue, 23 Dec 2025 01:41:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1766454091; cv=none; b=cNVL83ndxg4gWUcEJe6goYTMej6o1ZyihH1e2SLU7uIAxROR9bTT+cEGz+KfdQf/K0WkCaU6TV84PcpNnCDsFehS9T/kb4iy19LD3GAWxFNWQ2xESv5kFZO7i13b/eKCChuViIx7uDofw39YMtefUWX1JH8NqFb25Hfdp4nWe2Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1766454091; c=relaxed/simple;
	bh=Dw1tVh0CmnWqKDbnt9xHH3i4dpkMlWgLPtv4rSVZoxQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Wb1+Ru68OjCEY7d198CYqso/1y2KJ5dEqbaigI8DO+78twc6/phQpAlrVRB9uUPOFe4NUsbNxaONFIkzbIHUVlHqlxOUpBTcwGnY9ZgYDICEgs6l3YhDEzuKvZ7lfWPYOr/CCpy6E0HjrJPwxjs4ATU+e4RNb+zYnCXnUPhossI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QH9Er5tL; arc=none smtp.client-ip=209.85.167.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QH9Er5tL"
Received: by mail-lf1-f54.google.com with SMTP id 2adb3069b0e04-595910c9178so3672971e87.1
        for <lvm-devel@lists.linux.dev>; Mon, 22 Dec 2025 17:41:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1766454088; x=1767058888; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Uzc2azkAT7+UZs63CJT4nkeSpZYqRpvq+hUurVd9/nU=;
        b=QH9Er5tLKSDXsw+y5TBI3FaoIfAswLvgpypxyItphH6Uhxyt3dDSof/0NU4yDjfcUF
         9UsG14jjtbRvsfayTcTd3u/t8gvZVhFCPZtYLcps6kr4ltxnUVPgW0x+Apgcp6c19xOU
         xnSjpDUOd2v8EdDmuNXSO4+uqeSl94BerVzoV6fsR+4fM/vKIaDqlggNDlM/Y2oiHEPx
         OeXImPhXPPYW1JFF0chWCi77cUv+L5I411E2w2JZXw+dwwTMlED30KMNglfewmRtRQ94
         5mNBziFms9NGi5idHJL/+SznHtvkPFhHbPQ7W6PxXS6r1+f4Wtn6K14q5STFN+r+p2dW
         4dzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1766454088; x=1767058888;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Uzc2azkAT7+UZs63CJT4nkeSpZYqRpvq+hUurVd9/nU=;
        b=D+XQ1YAtGaGvtXvJPJpp9Mkf/yfNf9N9lZj96b5aV+uausDlEmT04zIcvhzL2dMe+8
         sZksNRFxtE2ncJaiPJcNtoUq+RgohDh0ur//3K3qPeyQ9M2ISr3RDAybpfFpNDwojOK+
         npOAbpKMjuyziL/0+AuWIwAB30FmJbHTqmEQIKNGw7wLDE0qTvDEyd0lgI4YCnoPKE7C
         WBMWcUdOtLND0k2AUi63CYvlN2GKE2vpKc1c1OVsEhpJKmOzNkAa+iA2DY50qyKQk1DO
         HmsZJ79jXtm42+0qUytjzdWH5oL0fdJFgQNFct7AyRSREbbHbaj1rWSaiDG9DpV/JgGN
         vP4w==
X-Forwarded-Encrypted: i=1; AJvYcCXVgNs9L7hpBbgPj1cFYW+7XYJ3J3MgQkdeunEBBwB5ceQRXudm5YvWyi0rCErGk+Xt8hA6oIwmUgs=@lists.linux.dev
X-Gm-Message-State: AOJu0YyJS7VpbeK04la9CtvfKZGlOrwUOx0ErOUVRoBdQQHwlTW4xnVJ
	4rEqT9mmISTjDoD/0dRuFDjK2dcae5Q/SC+2rkpb1NM9yAnv0459DyS7
X-Gm-Gg: AY/fxX6TlLYC2JPNwHfFcgWslPBmY9lgmA+FQyqdsfAzIZmLVQrw5pddYLV5bS1MG1P
	tCK2EasxDY5E+2121rqjdciXxe86Qbb4BlaS4C6oQIj8x0k43fenF4fcrQsS4JQt8O8/4iZBHHy
	LujFMxuoRu40U/jKn1Jow4J6KpbHyezqjert60cWeligxjDedYPgkQNEOnzxKGdYardg+w7lRQy
	ytgVgw8gzZYHc6m6i1W2vlcueodZ2l9OZRncessdNgFyo74yd236uqnDskpshGBu93ZwEZKXXLs
	cOeSY6PtSWnQZG9qtyNb7FCQWC3lA5JqW3MNIWaOowqMRtnQ3wnEfNHfFqxhwU2fdhgz0u2XYNr
	4WQIP9ULmgaoBoiZjlpiAd2uL8eq3aLSOln12m17tFGHJouerWmhbu3XwpvtdWJn0Khf/iTGJnV
	y8JRVs1qCF
X-Google-Smtp-Source: AGHT+IHWUix04V1tUMjJhj8LmwIJFsrYjMJ2eegt/yizChdKwHOARh8H0MmDtl7KvKnzF0od4dTcxA==
X-Received: by 2002:a05:6512:234b:b0:59a:123e:69ab with SMTP id 2adb3069b0e04-59a17d08c20mr4858078e87.10.1766454087534;
        Mon, 22 Dec 2025 17:41:27 -0800 (PST)
Received: from localhost ([194.190.17.114])
        by smtp.gmail.com with UTF8SMTPSA id 2adb3069b0e04-59a185d5ea6sm3600776e87.5.2025.12.22.17.41.25
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 22 Dec 2025 17:41:27 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: gmazyland@gmail.com
Cc: Dell.Client.Kernel@dell.com,
	dm-devel@lists.linux.dev,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	mpatocka@redhat.com,
	pavel@ucw.cz,
	rafael@kernel.org
Subject: Re: [RFC PATCH 2/2] swsusp: make it possible to hibernate to device mapper devices
Date: Tue, 23 Dec 2025 04:41:14 +0300
Message-ID: <20251223014114.2193668-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <86300955-72e4-42d5-892d-f49bdf14441e@gmail.com>
References: <86300955-72e4-42d5-892d-f49bdf14441e@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Milan Broz <gmazyland@gmail.com>:
> Anyway, my understanding is that all device-mapper targets use mempools,
> which should ensure that they can process even under memory pressure.

Also, I don't understand how mempools help here.

As well as I understand, allocation from mempool is still real allocation
if mempool's own reserve is over.

-- 
Askar Safin
