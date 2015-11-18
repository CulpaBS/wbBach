-- | Debugging Futhark programs is done by inserting calls to special
-- functions (currently only @trace@).  These are specially handled in
-- the type checker and interpreter, but not necessarily by other
-- transformations, so it may be necessary to remove them before
-- running optimisation passes.
module Futhark.Pass.Untrace
  ( untraceProg )
  where

import Futhark.Representation.Basic
import Futhark.Pass
import Futhark.Tools

-- | Remove all special debugging function calls from the program.
untraceProg :: Pass Basic Basic
untraceProg = simplePass
              "untrace"
              "Remove debugging annotations from program." $
              intraproceduralTransformation $ return . untraceFun

untraceFun :: FunDec -> FunDec
untraceFun (FunDec fname ret params body) =
  FunDec fname ret params (untraceBody body)

untraceBody :: Body -> Body
untraceBody = mapBody untraceBinding
  where untrace = identityMapper {
                    mapOnBody = return .untraceBody
                  , mapOnLambda = return . untraceLambda
                  }
        untraceBinding bnd@(Let _ _ (PrimOp _)) = bnd
        untraceBinding (Let pat attr e) =
          Let pat attr $ untraceExp e
        untraceExp (Apply fname [(e,_)] _)
          | "trace" <- nameToString fname = PrimOp $ SubExp e
        untraceExp e = mapExp untrace e


untraceLambda :: Lambda -> Lambda
untraceLambda lam =
  lam { lambdaBody = untraceBody $ lambdaBody lam }