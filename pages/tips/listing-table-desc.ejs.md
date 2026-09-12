<%
const onclick = () => ` onclick="href = this.querySelector('a').getAttribute('href');\n if (href) { window.location=href ; return false; }"`;
%>

```{=html}
<table class="quarto-listing-table table table-hover">
<thead>
<tr>

<th>
<a class="sort" data-sort="listing-title-sort" onclick="if (this.classList.contains('sort-asc')) { this.classList.add('sort-desc'); this.classList.remove('sort-asc') } else { this.classList.add('sort-asc'); this.classList.remove('sort-desc')} return false;">タイトル</a>
</th>

<th>
<a class="sort" data-sort="listing-date-sort" onclick="if (this.classList.contains('sort-asc')) { this.classList.add('sort-desc'); this.classList.remove('sort-asc') } else { this.classList.add('sort-asc'); this.classList.remove('sort-desc')} return false;">公開日</a>
</th>

</tr>
</thead>
<tbody class="list">
<% for (const item of items) { %>

<tr <%= metadataAttrs(item) %><%= onclick() %>>
```

<td><a href="<%- item.path %>" class="title listing-title"><%= item.title %></a><% if (item.description) { %><div class="listing-table-description"><%= item.description %></div><% } %></td>
<td><span class="listing-date"><%= item.date %></span></td>

```{=html}

</tr>
<% } %>
</tbody>
</table>
```
