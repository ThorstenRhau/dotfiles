# TS 32.158 Excerpts: REST Solution Set Design Rules

Source: 3GPP TS 32.158 V19.1.0 (2025-12)

---

## Clause 4: General Rules

### 4.1 Information Models and Resources

#### 4.1.3 Resource Archetypes

| Archetype | Description |
|-----------|-------------|
| **Document resource** | Standard resource with name-value pairs and links. Represents real-world object or logical concept. |
| **Collection resource** | Groups resources of same kind. Items typically document resources. Also called container resources. |
| **Operation resource** | Represents executable functions with input/output parameters. Fallback to RPC style when CRUD doesn't fit. |

#### 4.1.4 Mapping Information Models to Resources

- Managed object instances → Document resources (primary)
- Attributes → Secondary resources
- Collection resources have no direct equivalent in information model

### 4.2 Managed Object Naming and Resource Identification

#### 4.2.1.0 Distinguished Name (DN)

DN = comma-separated list of RDNs (Relative Distinguished Names)
- RDN format: `{className}={id}`
- Optional DC (Domain Component) prefix for global uniqueness

Example:
```
DN = "DC=operatorA.com,SubNetwork=south,ManagedElement=a,ENBFunction=1,Cell=1"
```

#### 4.2.3 Mapping DNs to URIs

**Rules:**
- DN prefix → authority component (reformatted as FQDN)
- LDN → path component (comma replaced with slash, equals sign preserved)

**Example mapping:**
```
LDN = "SubNetwork=south,ManagedElement=a,ENBFunction=1,Cell=1"
URI-LDN = "/SubNetwork=south/ManagedElement=a/ENBFunction=1/Cell=1"

DN-prefix = "DC=operatorA.com"
URI-DN-prefix = "operatorA.com"

Full URI: http://operatorA.com/SubNetwork=south/ManagedElement=a/ENBFunction=1/Cell=1
```

### 4.3 Message Content Formats

#### 4.3.1 Media Types

**Standard media types:**
- `application/json` - Default for request/response bodies
- `application/merge-patch+json` - JSON Merge Patch (RFC 7396)
- `application/json-patch+json` - JSON Patch (RFC 6902)

**3GPP-specific media types:**
- `application/vnd.3gpp.merge-patch+json` - 3GPP JSON Merge Patch
- `application/vnd.3gpp.json-patch+json` - 3GPP JSON Patch
- `application/vnd.3gpp.object-tree-hierarchical+json` - Hierarchical response
- `application/vnd.3gpp.object-tree-flat+json` - Flat response

### 4.4 URI Structure

#### 4.4.2 URI Structure for Resources Representing Managed Objects

```
{scheme}://{URI-DN-prefix}/{root}/{MnSName}/{MnSVersion}/{URI-LDN}
```

| Component | Description |
|-----------|-------------|
| {scheme} | "http" or "https" |
| {URI-DN-prefix} | Authority (host + optional port) |
| {root} | Optional path segments for structuring |
| {MnSName} | Optional MnS name (single path segment) |
| {MnSVersion} | Optional MnS version (single path segment) |
| {URI-LDN} | Path constructed from LDN |

**Abbreviated form:**
```
{MnSRoot}/{MnSName}/{MnSVersion}/{URI-LDN}
```

**Examples:**
```
http://operatorA.com/ProvMnS/v15/SubNetwork=south/.../Cell=1
http://operatorA.com/ProvMnS/v16/SubNetwork=south/.../Cell=1
http://operatorA.com/3gppManagement/cm/ProvMnS/v1/SubNetwork=south/.../Cell=1
```

#### 4.4.4 Resource "../{MnSName}/{MnSVersion}" (NRM Root)

- Conceptual parent of top-level managed object instances
- Created by MnS Producer (cannot be created/deleted by Consumer)
- Target for requests when no managed objects exist yet
- Attempts to read NRM root only shall return "204 No Content"

---

## Clause 5: Basic Design Patterns

### 5.1 Creating a Resource

#### 5.1.1 With Identifier Creation by MnS Producer (HTTP POST)

```
POST /parent-resource HTTP/1.1
Content-Type: application/json

{resource representation without id, with className}
```

**Response:** `201 Created` with Location header containing new URI

**Rules:**
- Target URI = parent resource
- No query or fragment component in URI
- Resource representation shall NOT contain child resources
- Parent resource must exist

#### 5.1.2 With Identifier Creation by MnS Consumer (HTTP PUT)

```
PUT /parent-resource/{className}={id} HTTP/1.1
Content-Type: application/json

{resource representation with id and className}
```

**Response:** `201 Created` with Location header

### 5.2 Reading a Resource (HTTP GET)

```
GET /resource-uri HTTP/1.1
Accept: application/json
```

**Response:** `200 OK` with resource representation

### 5.3 Updating a Resource (HTTP PUT)

```
PUT /resource-uri HTTP/1.1
Content-Type: application/json

{complete new representation}
```

**Response:** `200 OK` or `204 No Content`

**Important:** PUT has **replace semantics**, not merge semantics. The complete existing representation is replaced.

### 5.4 Deleting a Resource (HTTP DELETE)

```
DELETE /resource-uri HTTP/1.1
```

**Response:** `204 No Content`

**Rule:** Only **leaf resources** can be deleted. Deleting non-leaf resources returns `409 Conflict`.

---

## Clause 6: Advanced Design Patterns

### 6.1 Scoping and Filtering

#### 6.1.2 Query Parameters for Scoping

| scopeType Value | Description |
|-----------------|-------------|
| BASE_ONLY | Selects only base resource (default if absent) |
| BASE_ALL | Selects base and all descendants including leaves |
| BASE_NTH_LEVEL | Selects resources at specified level below base |
| BASE_SUBTREE | Selects base and descendants down to specified level |

Example: `?scopeType=BASE_ALL`

#### 6.1.3 Query Parameters for Filtering

- Parameter name: `filter`
- Uses Jex expressions (TS 32.161)
- Applied to JSON document of scoped objects

Example: `?filter=/attributes/userLabel="test"`

### 6.2 Attribute Selection

**Query parameters:**
- `attributes` - Comma-separated list of attribute names
- `fields` - Comma-separated JSON Pointer paths

Example: `?attributes=userLabel,administrativeState`

### 6.3 Partial Update (HTTP PATCH)

#### 6.3.2 JSON Merge Patch

Media type: `application/merge-patch+json`

**Operations:**
1. Replace value of existing name/value pair
2. Add new name/value pair
3. Remove name/value pair (set to null)

**Example - Add/Replace attribute:**
```
PATCH /SubNetwork=SN1/ManagedElement=ME1/XyzFunction=XYZF1 HTTP/1.1
Content-Type: application/merge-patch+json

{
  "id": "XYZF1",
  "attributes": {
    "attrA": "newValue"
  }
}
```

**Example - Delete attribute:**
```
{
  "id": "XYZF1",
  "attributes": {
    "attrA": null
  }
}
```

**Limitations:**
- Cannot modify individual array items (only replace entire array)
- Shall not be used for creating/modifying/deleting child resources

#### 6.3.3 JSON Patch

Media type: `application/json-patch+json`

**Operations:** add, replace, remove, copy, move, test

**Example - Add attribute:**
```
PATCH /SubNetwork=SN1/ManagedElement=ME1/XyzFunction=XYZF1 HTTP/1.1
Content-Type: application/json-patch+json

[
  {
    "op": "add",
    "path": "/attributes/attrA",
    "value": "abc"
  }
]
```

**Example - Replace attribute:**
```
[
  {
    "op": "replace",
    "path": "/attributes/attrA",
    "value": "def"
  }
]
```

**Example - Remove attribute:**
```
[
  {
    "op": "remove",
    "path": "/attributes/attrA"
  }
]
```

**Array manipulation:** Uses index-based addressing (0, 1, 2...; "-" for append)

### 6.4 Patching Multiple Resources

#### 6.4.2 3GPP JSON Merge Patch

Media type: `application/vnd.3gpp.merge-patch+json`

Extends JSON Merge Patch to support multiple resources in containment hierarchy.

#### 6.4.3 3GPP JSON Patch

Media type: `application/vnd.3gpp.json-patch+json`

Extends JSON Patch to support multiple resources using DN-based addressing.

---

## Clause 7: Resource Representation Formats

### 7.6 Resource Objects

**Standard structure:**
```json
{
  "id": "identifier",
  "objectClass": "ClassName",
  "objectInstance": "DN-string",
  "attributes": {
    "attrA": "value",
    "attrB": 123
  },
  "ChildClass": [...]
}
```

**Required properties:**
- `id` - Resource identifier (naming attribute value)

**Optional properties:**
- `objectClass` - Class name
- `objectInstance` - DN of the resource
- `attributes` - Object containing attribute name-value pairs
- Child resources as arrays

---

## OpenAPI/YAML Naming Conventions

| NRM Element | OpenAPI Convention | Example |
|-------------|-------------------|---------|
| IOC name | UpperCamelCase | `ManagedElement` |
| Attribute name | lowerCamelCase | `userLabel` |
| Data type | UpperCamelCase | `AdministrativeState` |
| Schema file | TS{number}_{name}.yaml | `TS28623_GenericNrm.yaml` |

---

## HTTP Status Codes Summary

| Code | Meaning | Usage |
|------|---------|-------|
| 200 OK | Success with body | GET, PUT, PATCH responses |
| 201 Created | Resource created | POST, PUT (create) |
| 204 No Content | Success, no body | DELETE, PUT/PATCH (no changes) |
| 400 Bad Request | Malformed request | Syntax errors |
| 404 Not Found | Resource doesn't exist | Invalid URI |
| 406 Not Acceptable | Unsupported media type | Content negotiation failure |
| 409 Conflict | Operation conflict | Delete non-leaf resource |
