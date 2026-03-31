const frame = document.querySelector(".frame");
let lastScrollTop = 0;

function createSqlToken(type, value) {
  const token = document.createElement("span");
  token.className = `sql-${type}`;
  token.dataset.sqlToken = "true";
  token.textContent = value;
  return token;
}

function highlightSqlText(text) {
  const tokenPattern =
    /(--[^\n]*|'(?:''|[^'])*'|"(?:[^"]|"")*"|:[A-Za-z_][A-Za-z0-9_]*|\b\d+(?:\.\d+)?\b|\b(?:SELECT|FROM|WHERE|AND|OR|INNER|LEFT|RIGHT|FULL|OUTER|JOIN|ON|CASE|WHEN|THEN|ELSE|END|IF|BEGIN|DECLARE|DEFAULT|INTEGER|DECIMAL|DATE|NVARCHAR|NCHAR|LANGUAGE|SQLSCRIPT|AS|CREATE|PROCEDURE|CALL|FOR|DO|CURSOR|INTO|UPDATE|INSERT|VALUES|DELETE|SET|GROUP|BY|ORDER|TOP|SUM|COUNT|MAX|MIN|ROUND|IFNULL|CURRENT_TIMESTAMP|YEAR|DISTINCT|NULL|IS|NOT|IN|EXISTS|RETURN|RETURNS|WHILE|LOOP)\b)/gi;
  const fragment = document.createDocumentFragment();
  let lastIndex = 0;
  let hasMatch = false;
  let match;

  while ((match = tokenPattern.exec(text))) {
    hasMatch = true;

    if (match.index > lastIndex) {
      fragment.append(document.createTextNode(text.slice(lastIndex, match.index)));
    }

    const tokenValue = match[0];
    let tokenType = "keyword";

    if (tokenValue.startsWith("--")) {
      tokenType = "comment";
    } else if (tokenValue.startsWith("'")) {
      tokenType = "string";
    } else if (tokenValue.startsWith('"')) {
      tokenType = "identifier";
    } else if (tokenValue.startsWith(":")) {
      tokenType = "param";
    } else if (/^\d/.test(tokenValue)) {
      tokenType = "number";
    }

    fragment.append(createSqlToken(tokenType, tokenValue));
    lastIndex = tokenPattern.lastIndex;
  }

  if (!hasMatch) {
    return null;
  }

  if (lastIndex < text.length) {
    fragment.append(document.createTextNode(text.slice(lastIndex)));
  }

  return fragment;
}

function walkSqlNodes(node) {
  [...node.childNodes].forEach((child) => {
    if (child.nodeType === Node.TEXT_NODE) {
      const highlighted = highlightSqlText(child.textContent || "");

      if (highlighted) {
        child.replaceWith(highlighted);
      }

      return;
    }

    if (child.nodeType === Node.ELEMENT_NODE && !child.dataset.sqlToken) {
      walkSqlNodes(child);
    }
  });
}

function highlightSqlBlocks() {
  document.querySelectorAll("pre code").forEach((block) => {
    walkSqlNodes(block);
  });
}

if (frame) {
  window.addEventListener(
    "scroll",
    () => {
      const currentScrollTop = window.scrollY || document.documentElement.scrollTop;

      if (currentScrollTop <= 24) {
        frame.classList.remove("is-hidden");
        lastScrollTop = currentScrollTop;
        return;
      }

      const isScrollingDown = currentScrollTop > lastScrollTop;
      frame.classList.toggle("is-hidden", isScrollingDown && currentScrollTop > 140);
      lastScrollTop = currentScrollTop;
    },
    { passive: true }
  );
}

highlightSqlBlocks();
