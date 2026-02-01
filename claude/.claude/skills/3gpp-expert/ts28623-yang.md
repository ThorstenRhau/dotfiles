# TS 28.623 Excerpts: YANG Solution Set Guidelines

Source: 3GPP TS 28.623 V20.0.0 (2025-12)

---

## Clause 4: Solution Set Definitions

### 4.3 OpenAPI Definitions

OpenAPI/YAML definitions are specified in 3GPP Forge:
- Directory: `OpenAPI`
- Mapping rules: TS 32.160

**Key files:**
- `TS28623_ComDefs.yaml` - Common definitions
- `TS28623_GenericNrm.yaml` - Generic NRM
- `TS28623_PmControlNrm.yaml` - PM Control
- `TS28623_ThresholdMonitorNrm.yaml` - Threshold Monitor
- `TS28623_SubscriptionControlNrm.yaml` - Subscription Control
- `TS28623_MnSRegistryNrm.yaml` - MnS Registry
- `TS28623_FileManagementNrm.yaml` - File Management
- `TS28623_TraceControlNrm.yaml` - Trace Control

### 4.4 YANG Definitions

YANG definitions are specified in 3GPP Forge:
- Directory: `yang-models`
- Mapping rules: TS 32.160

**Key modules:**
- `_3gpp-common-top.yang` - Top-level groupings
- `_3gpp-common-managed-element.yang` - ManagedElement
- `_3gpp-common-managed-function.yang` - ManagedFunction base
- `_3gpp-common-subnetwork.yang` - SubNetwork
- `_3gpp-common-yang-types.yang` - 3GPP YANG types
- `_3gpp-common-yang-extensions.yang` - 3GPP YANG extensions

---

## YANG Module Structure

### Module Naming Convention

```
_3gpp-{domain}-{function}.yang
```

**Examples:**
- `_3gpp-common-managed-element.yang`
- `_3gpp-nr-nrm-gnbdufunction.yang`
- `_3gpp-5gc-nrm-amffunction.yang`

**Note:** Leading underscore required because module names cannot start with digit.

### Standard Module Header

```yang
module _3gpp-nr-nrm-gnbdufunction {
  yang-version 1.1;
  namespace "urn:3gpp:sa5:_3gpp-nr-nrm-gnbdufunction";
  prefix gnbdu3gpp;

  import _3gpp-common-managed-element { prefix me3gpp; }
  import _3gpp-common-top { prefix top3gpp; }
  import _3gpp-common-yang-types { prefix types3gpp; }

  organization "3GPP SA5";
  contact "https://www.3gpp.org/Specifications-Desk";
  description "GnbDuFunction NRM fragment";

  revision 2025-xx-xx {
    description "Initial revision";
    reference "3GPP TS 28.541";
  }

  // ... content ...
}
```

### Containment via Augmentation

```yang
augment "/me3gpp:ManagedElement" {
  list GnbDuFunction {
    key "id";
    uses top3gpp:Top_Grp;

    leaf userLabel {
      type string;
      description "User-defined label";
    }
    // ... other leaves ...
  }
}
```

---

## YANG Naming Conventions

### NRM to YANG Mapping

| NRM Element | YANG Convention | Example |
|-------------|-----------------|---------|
| IOC name | kebab-case for module, CamelCase for list/container | `gnb-du-function` module, `GnbDuFunction` list |
| Attribute name | lowerCamelCase | `userLabel` |
| Data type | CamelCase | `AdministrativeState` |
| Module prefix | abbreviated + `3gpp` suffix | `gnbdu3gpp` |

### Attribute Naming

- Use lowerCamelCase (same as OpenAPI)
- Multi-word: `userLabel`, `administrativeState`, `operationalState`
- Abbreviations: preserve case from NRM (`plmnId`, `nrCgi`)

---

## Data Type Mapping

### Stage-2 to YANG Type Mapping

| Stage-2 Type | YANG Type | Notes |
|--------------|-----------|-------|
| String | string | |
| Integer | int32 / int64 | |
| Boolean | boolean | |
| Enum | enumeration | |
| DateTime | yang:date-and-time | From ietf-yang-types |
| DN | types3gpp:DistinguishedName | 3GPP defined |
| Float | decimal64 fraction-digits 1-7 | RFC 7950 |
| Real | decimal64 fraction-digits 8-18 | RFC 7950 |
| Uri | inet:uri | From ietf-inet-types |
| Fqdn | inet:host-name | From ietf-inet-types |
| Ipv4Addr | inet:ipv4-address | From ietf-inet-types |
| Ipv6Addr | inet:ipv6-address | From ietf-inet-types |
| Ipv6Prefix | inet:ipv6-prefix | From ietf-inet-types |
| DnList | leaf-list of types3gpp:DistinguishedName | |
| FullTime | yang:time-with-zone-offset | From ietf-yang-types |

### Common 3GPP Types

```yang
// In _3gpp-common-yang-types.yang
typedef DistinguishedName {
  type string;
  description "3GPP Distinguished Name format";
}

typedef Mcc {
  type string {
    pattern '[0-9]{3}';
  }
  description "Mobile Country Code";
}

typedef Mnc {
  type string {
    pattern '[0-9]{2,3}';
  }
  description "Mobile Network Code";
}
```

---

## Mount Points

### Schema Mount (RFC 8528)

YANG Schema Mount allows adding schema trees at designated mount points.

**Mount point for SubNetwork children:**
```yang
// In _3gpp-common-subnetwork.yang
container SubNetwork {
  // ...
  sx:mount-point "children-of-SubNetwork" {
    description "Mount point for IOCs contained under SubNetwork";
  }
}
```

**Mount point for MeContext children:**
```yang
// In _3gpp-common-mecontext.yang
container MeContext {
  // ...
  sx:mount-point "children-of-MeContext" {
    description "Mount point for ManagedElement hierarchy";
  }
}
```

### Mount Information Discovery

- Use `ietf-yang-library` (RFC 8525) to list supported modules
- Use `ietf-netconf-monitoring` (RFC 6022) with `<get-schema>` to retrieve modules

---

## Annex E.2: YANG/NETCONF Solution Set

### E.2.1 NRM Properties Supported

The YANG module `ietf-yang-library` (RFC 8525) is available via NETCONF at the `mnsAddress`. Individual supported YANG modules accessible via:
- `ietf-netconf-monitoring` with `<get-schema>` operation
- `ietf-yang-library` module locations

### E.2.2 Common Data Type Exceptions

| Stage-2 Type | YANG Type | Source |
|--------------|-----------|--------|
| FullTime | yang:time-with-zone-offset | ietf-yang-types.yang |
| Float | decimal64 (fraction-digits 1-7) | RFC 7950 |
| DN | types3gpp:DistinguishedName | _3gpp-common-yang-types.yang |
| Real | decimal64 (fraction-digits 8-18) | RFC 7950 |
| DnList | leaf-list of types3gpp:DistinguishedName | |
| Fqdn | inet:host-name | ietf-inet-types.yang |
| Ipv4Addr | inet:ipv4-address | ietf-inet-types.yang |
| Ipv6Addr | inet:ipv6-address | ietf-inet-types.yang |
| Ipv6Prefix | inet:ipv6-prefix | ietf-inet-types.yang |
| Uri | inet:uri | ietf-inet-types.yang |

---

## YANG Validation Checklist

### Module Compilation
- [ ] `pyang` validates without errors
- [ ] Namespace unique across all modules
- [ ] All imports have correct prefix declarations
- [ ] Revision date present and formatted correctly

### Augmentation
- [ ] Target path exists in base module
- [ ] Base module properly imported
- [ ] Augment statement outside module body uses absolute path

### List Definitions
- [ ] All lists have `key` statement
- [ ] Key leaf(s) defined within the list
- [ ] Uses `top3gpp:Top_Grp` for standard attributes

### Data Types
- [ ] Enum values match NRM exactly
- [ ] String patterns correct (regex syntax)
- [ ] Numerical ranges within type bounds
- [ ] References to external types have correct prefix

---

## Common YANG Patterns

### IOC with Attributes

```yang
list GnbDuFunction {
  key "id";
  uses top3gpp:Top_Grp;

  container attributes {
    leaf userLabel {
      type string;
      description "User-defined label for the object";
    }

    leaf administrativeState {
      type types3gpp:AdministrativeState;
      description "Administrative state of the function";
    }

    leaf operationalState {
      type types3gpp:OperationalState;
      config false;
      description "Operational state (read-only)";
    }
  }
}
```

### Enumeration

```yang
typedef AdministrativeState {
  type enumeration {
    enum LOCKED {
      description "Resource is administratively locked";
    }
    enum UNLOCKED {
      description "Resource is administratively unlocked";
    }
    enum SHUTTINGDOWN {
      description "Resource is transitioning to locked";
    }
  }
  description "Administrative state values per ITU-T X.731";
}
```

### Reference Attribute (DN)

```yang
leaf managedElementRef {
  type types3gpp:DistinguishedName;
  description "DN of the referenced ManagedElement";
}

leaf-list plmnIdList {
  type types3gpp:PLMNId;
  description "List of PLMN identifiers";
}
```

---

## OpenAPI vs YANG Comparison

| Aspect | OpenAPI (REST) | YANG (NETCONF) |
|--------|----------------|----------------|
| IOC names | CamelCase | CamelCase (in list), kebab-case (in module name) |
| Attributes | camelCase | camelCase |
| File extension | `.yaml` | `.yang` |
| Containment | Nested objects/arrays | augment statements |
| References | `$ref` | `import` + prefix |
| Versioning | OpenAPI version field | revision statement |
| Media type | application/json | application/yang-data+xml or +json |
