/**
 * @name javascript_obfuscator_A
 * @description Obfuscation
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision low
 * @id npm/epic-ue-fonts
 * @tags security
 *       obfuscator
 *       taint
 */

import javascript
import DataFlow::PathGraph


// The malicious package was obfuscated using "JavaScript Obfuscator Tool" (https://obfuscator.io).
// A particular aspect of this tool is that it stores function names as strings in an array, which
// are retrieved during execution making it hard to statically analyze.

// The following query is just an attempt to capture this highly suspicious behaviour.

// Hints of Obfuscation
// --------------------
// >) Sorting
// >>>) array literal > take an element > apply parseInt                 | (OK)
// >>>) array literal > apply push-&-shift                               | (OK)
// >) Flow
// >>>) array literal > take an element > use for method-call naming     | (OK)
// >) Other
// >>>) array literal > check an element > has "num-char" string format  | (OK)
// >>>) array literal > compute a magic-number index > take an element   | (--)
// >>>) array literal > take some elements > compute a magic-number      | (--)


class TargetArray extends DataFlow::ArrayLiteralNode {
    // CharPred
    TargetArray() {
        // At least one element is a string with "digits-letters" format
        exists( DataFlow::ValueNode n, string s
              | n = this.getAnElement()
              | n.mayHaveStringValue(s) and s.regexpMatch("[0-9]+[a-zA-Z]+")
              )
    }
}


// Taint-Tracking configuration for this problem
class Obfuscator_Configuration extends TaintTracking::Configuration {
    Obfuscator_Configuration() { this = "Obfuscator" }

    // Source: Array with suspicious strings
    override predicate isSource(DataFlow::Node source) { source instanceof TargetArray }

    // Sink: Obfuscated method-call
    override predicate isSink(DataFlow::Node sink) {
        // Access for a computed-property (from array value) to a method-call
        exists( DataFlow::MethodCallNode call, DataFlow::PropRead access, Expr property
              | call.getCalleeNode() = access and access.getPropertyNameExpr() = property
              | property.flow() = sink
              )
    }
}


// Taint-Tracking configuration for this problem
class ArrayParse_Configuration extends TaintTracking::Configuration {
    ArrayParse_Configuration() { this = "Array ParseInt" }

    // Source: Array with suspicious strings
    override predicate isSource(DataFlow::Node source) { source instanceof TargetArray }

    // Sink: Applying parseInt() to some of the values
    override predicate isSink(DataFlow::Node sink) {
        exists( DataFlow::CallNode parse
              | parse.getCalleeName() = "parseInt"
              | parse.getAnArgument() = sink
              )
    }
}


// Taint-Tracking configuration for this problem
class ArrayCycle_Configuration extends TaintTracking::Configuration {
    ArrayCycle_Configuration() { this = "Array Push-&-Shift" }

    // Source: Array with suspicious strings
    override predicate isSource(DataFlow::Node source) { source instanceof TargetArray }

    // Sink: Applying .push() & .shift() to the array
    override predicate isSink(DataFlow::Node sink) {
        exists( DataFlow::MethodCallNode call_S, DataFlow::MethodCallNode call_P, DataFlow::Node node_S, DataFlow::Node node_P
              | node_S.getALocalSource() = sink and call_S.calls(node_S, "shift")
            and node_P.getALocalSource() = sink and call_P.calls(node_P, "push")
              | call_P.getAnArgument() = call_S
              )
    }
}


from Obfuscator_Configuration cfg,
     ArrayParse_Configuration parse,
     ArrayCycle_Configuration cycle,
     DataFlow::PathNode source, DataFlow::PathNode sink,
     int p_COUNT, int c_COUNT
where cfg.hasFlowPath(source, sink)
  // Be sure that source and sink are in the same file
  and source.getNode().getFile() = sink.getNode().getFile()
  // Be sure that parseInt() gets applied to some of the values (and count them)
  and p_COUNT = strictcount( DataFlow::Node p_SINK
                           | parse.hasFlow(source.getNode(), p_SINK)
                           )
  // Be sure that .push() & .shift() get applied to the array (and count it)
  and c_COUNT = strictcount( DataFlow::Node c_SINK
                           | cycle.hasFlow(source.getNode(), c_SINK)
                           )
select sink.getNode(),
       source,
       sink,
       "$@ to $@ | PARSE: " + p_COUNT + " | CYCLE: " + c_COUNT,
       source.getNode(),
       "SOURCE",
       sink.getNode(),
       "SINK"
