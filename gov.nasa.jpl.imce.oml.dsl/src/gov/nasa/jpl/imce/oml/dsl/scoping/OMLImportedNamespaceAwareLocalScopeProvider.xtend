/*
 * Copyright 2016 California Institute of Technology ("Caltech").
 * U.S. Government sponsorship acknowledged.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * License Terms
 */
package gov.nasa.jpl.imce.oml.dsl.scoping

import com.google.inject.Inject
import gov.nasa.jpl.imce.oml.dsl.util.OMLImportNormalizer
import gov.nasa.jpl.imce.oml.model.bundles.Bundle
import gov.nasa.jpl.imce.oml.model.bundles.BundledTerminologyAxiom
import gov.nasa.jpl.imce.oml.model.bundles.BundlesPackage
import gov.nasa.jpl.imce.oml.model.bundles.DisjointUnionOfConceptsAxiom
import gov.nasa.jpl.imce.oml.model.bundles.RootConceptTaxonomyAxiom
import gov.nasa.jpl.imce.oml.model.bundles.SpecificDisjointConceptAxiom
import gov.nasa.jpl.imce.oml.model.common.Annotation
import gov.nasa.jpl.imce.oml.model.common.CommonPackage
import gov.nasa.jpl.imce.oml.model.common.Extent
import gov.nasa.jpl.imce.oml.model.common.ModuleEdge
import gov.nasa.jpl.imce.oml.model.descriptions.ConceptInstance
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBox
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBoxExtendsClosedWorldDefinitions
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionBoxRefinement
import gov.nasa.jpl.imce.oml.model.descriptions.DescriptionsPackage
import gov.nasa.jpl.imce.oml.model.descriptions.ReifiedRelationshipInstance
import gov.nasa.jpl.imce.oml.model.descriptions.ReifiedRelationshipInstanceDomain
import gov.nasa.jpl.imce.oml.model.descriptions.ReifiedRelationshipInstanceRange
import gov.nasa.jpl.imce.oml.model.descriptions.ScalarDataPropertyValue
import gov.nasa.jpl.imce.oml.model.descriptions.SingletonInstanceScalarDataPropertyValue
import gov.nasa.jpl.imce.oml.model.descriptions.SingletonInstanceStructuredDataPropertyValue
import gov.nasa.jpl.imce.oml.model.descriptions.StructuredDataPropertyTuple
import gov.nasa.jpl.imce.oml.model.descriptions.UnreifiedRelationshipInstanceTuple
import gov.nasa.jpl.imce.oml.model.graphs.ConceptDesignationTerminologyAxiom
import gov.nasa.jpl.imce.oml.model.graphs.GraphsPackage
import gov.nasa.jpl.imce.oml.model.graphs.TerminologyGraph
import gov.nasa.jpl.imce.oml.model.graphs.TerminologyNestingAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.AspectSpecializationAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.ConceptSpecializationAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityRelationship
import gov.nasa.jpl.imce.oml.model.terminologies.EntityRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityScalarDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.EntityScalarDataPropertyExistentialRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityScalarDataPropertyParticularRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityScalarDataPropertyUniversalRestrictionAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.EntityStructuredDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.ReifiedRelationshipSpecializationAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.RestrictedDataRange
import gov.nasa.jpl.imce.oml.model.terminologies.ScalarDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.ScalarOneOfLiteralAxiom
import gov.nasa.jpl.imce.oml.model.terminologies.StructuredDataProperty
import gov.nasa.jpl.imce.oml.model.terminologies.TerminologiesPackage
import gov.nasa.jpl.imce.oml.model.terminologies.TerminologyExtensionAxiom
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider

class OMLImportedNamespaceAwareLocalScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	
	@Inject IQualifiedNameConverter qnc
		
	override def List<ImportNormalizer> getImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		val res = new ArrayList<ImportNormalizer>();
		switch context {
			Extent:
				for (ap : context.annotationProperties)
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(ap.iri), ap.abbrevIRI))
			Bundle: {
				for (ap : context.extent.annotationProperties) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(ap.iri), ap.abbrevIRI))
				}
				for (e : context.boxAxioms) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(e?.target?.iri()?:""), e.target?.name?:""))
				}
				for (e : context.bundleAxioms) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(e?.target?.iri()?:""), e.target?.name?:""))
				}
			}
			TerminologyGraph: {
				for (ap : context.extent.annotationProperties) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(ap.iri), ap.abbrevIRI))
				}
				for (e : context.boxAxioms) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(e?.target?.iri()?:""), e.target?.name?:""))
				}
			}
			DescriptionBox: {
				for (ap : context.extent.annotationProperties) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(ap.iri), ap.abbrevIRI))
				}
				for (e : context.closedWorldDefinitions) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(e?.closedWorldDefinitions?.iri()?:""), e.closedWorldDefinitions?.name?:""))
				}
				for (e : context.descriptionBoxRefinements) {
					res.add(new OMLImportNormalizer(qnc.toQualifiedName(e?.refinedDescriptionBox?.iri()?:""), e.refinedDescriptionBox?.name?:""))
				}
			}
		}
		res.addAll(super.getImportedNamespaceResolvers(context, ignoreCase));
		
		
		return res;
	}
	
	@Inject extension OMLScopeExtensions
	
	override protected getImportedNamespace(EObject object) {
		switch object {
			ModuleEdge:
				object.targetModule?.iri()	
			default:
				super.getImportedNamespace(object)
		}	
	}
	
 	override getScope(EObject context, EReference reference) {
 		var IScope scope = null
		switch context {
 			Annotation:
 				if (reference == CommonPackage.eINSTANCE.annotation_Property) {
 					// @TODO replace with a proper scope definition.
 					// This is an ugly workaround to a proper scope definition.
 					// Usually, this workaround has the useful side effect to make the next scope, 's2', non-empty.
					val s1 = super.getScope(context, reference)
					val s2 = scope_Annotation_property(context, reference)
					val n2 = s2.allElements.size
					if (n2 == 0)
						scope = s1
					else
						scope = s2
				}
					
			TerminologyExtensionAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.terminologyExtensionAxiom_ExtendedTerminology)
					scope = context.tbox.allTerminologies
					
			EntityRelationship:
				if (reference == TerminologiesPackage.eINSTANCE.entityRelationship_Source ||
					reference == TerminologiesPackage.eINSTANCE.entityRelationship_Target)
					scope = context.tbox.allEntitiesScope
					
			AspectSpecializationAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.aspectSpecializationAxiom_SubEntity)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.aspectSpecializationAxiom_SuperAspect)
					scope = context.getTbox.allAspectsScope
					
			ConceptSpecializationAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.conceptSpecializationAxiom_SubConcept)
					scope = context.tbox.allConceptsScope
				else if (reference == TerminologiesPackage.eINSTANCE.conceptSpecializationAxiom_SuperConcept)
					scope = context.tbox.allConceptsScope
					
			ReifiedRelationshipSpecializationAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.reifiedRelationshipSpecializationAxiom_SubRelationship)
					scope = context.tbox.allReifiedRelationshipsScope
				else if (reference == TerminologiesPackage.eINSTANCE.reifiedRelationshipSpecializationAxiom_SuperRelationship)
					scope = context.tbox.allReifiedRelationshipsScope
					
			RestrictedDataRange:
				if (reference == TerminologiesPackage.eINSTANCE.restrictedDataRange_RestrictedRange)
					scope = context.tbox.allRangesScope
				
			EntityScalarDataProperty:
				if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipFromEntity_Domain)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipToScalar_Range)
					scope = context.tbox.allRangesScope
					
			EntityStructuredDataProperty:
				if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipFromEntity_Domain)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipToStructure_Range)
					scope = context.tbox.allStructuresScope
					
			ScalarDataProperty:
				if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipFromStructure_Domain)
					scope = context.tbox.allStructuresScope
				else if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipToScalar_Range)
					scope = context.tbox.allRangesScope
				
			StructuredDataProperty:
				if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipFromStructure_Domain)
					scope = context.tbox.allStructuresScope
				else if (reference == TerminologiesPackage.eINSTANCE.dataRelationshipToStructure_Range)
					scope = context.tbox.allStructuresScope
				
			EntityRestrictionAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.entityRestrictionAxiom_RestrictedRelation)
					scope = context.tbox.allEntityRelationshipsScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityRestrictionAxiom_RestrictedDomain)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityRestrictionAxiom_RestrictedRange)
					scope = context.tbox.allEntitiesScope
				
			EntityScalarDataPropertyExistentialRestrictionAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyRestrictionAxiom_RestrictedEntity)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyRestrictionAxiom_ScalarProperty)
					scope = context.tbox.allEntityScalarDataPropertiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyExistentialRestrictionAxiom_ScalarRestriction)
					scope = context.tbox.allRangesScope
				
			EntityScalarDataPropertyParticularRestrictionAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyRestrictionAxiom_RestrictedEntity)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyRestrictionAxiom_ScalarProperty)
					scope = context.tbox.allEntityScalarDataPropertiesScope
			
			EntityScalarDataPropertyUniversalRestrictionAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyRestrictionAxiom_RestrictedEntity)
					scope = context.tbox.allEntitiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyRestrictionAxiom_ScalarProperty)
					scope = context.tbox.allEntityScalarDataPropertiesScope
				else if (reference == TerminologiesPackage.eINSTANCE.entityScalarDataPropertyUniversalRestrictionAxiom_ScalarRestriction)
					scope = context.tbox.allRangesScope
				
			ScalarOneOfLiteralAxiom:
				if (reference == TerminologiesPackage.eINSTANCE.scalarOneOfLiteralAxiom_Axiom)
					scope = context.tbox.allScalarOneOfRestrictionsScope
				
			RootConceptTaxonomyAxiom:
				if (reference == BundlesPackage.eINSTANCE.rootConceptTaxonomyAxiom_Root)
					scope = context.bundle.allConceptsScope
					
			SpecificDisjointConceptAxiom:
				if (reference == BundlesPackage.eINSTANCE.specificDisjointConceptAxiom_DisjointLeaf)
					scope = context.disjointTaxonomyParent.bundleContainer().allConceptsScope
				
			DisjointUnionOfConceptsAxiom:
				{}
				
			BundledTerminologyAxiom:
				if (reference == BundlesPackage.eINSTANCE.bundledTerminologyAxiom_BundledTerminology)
					scope = scope_BundledTerminologyAxiom_bundledTerminology(context)
					
			ConceptDesignationTerminologyAxiom:
				if (reference == GraphsPackage.eINSTANCE.conceptDesignationTerminologyAxiom_DesignatedTerminology)
					scope = scope_ConceptDesignationTerminologyAxiom_designatedTerminology(context)
				else if (reference == GraphsPackage.eINSTANCE.conceptDesignationTerminologyAxiom_DesignatedConcept)
					scope = scope_ConceptDesignationTerminologyAxiom_designatedConcept(context)
					
			TerminologyNestingAxiom:
				if (reference == GraphsPackage.eINSTANCE.terminologyNestingAxiom_NestingTerminology)
					scope = context.tbox.allTerminologies
				else if (reference == GraphsPackage.eINSTANCE.terminologyNestingAxiom_NestingContext)
					scope = context.tbox.allConceptsScope
					
			DescriptionBoxExtendsClosedWorldDefinitions:
				if (reference == DescriptionsPackage.eINSTANCE.descriptionBoxExtendsClosedWorldDefinitions_ClosedWorldDefinitions)
					scope = context.descriptionBox.allTerminologies
				
			DescriptionBoxRefinement:
				if (reference == DescriptionsPackage.eINSTANCE.descriptionBoxRefinement_RefinedDescriptionBox)
					scope = context.descriptionDomain.allDescriptions
					
			SingletonInstanceScalarDataPropertyValue:
				if (reference == DescriptionsPackage.eINSTANCE.singletonInstanceScalarDataPropertyValue_SingletonInstance)
					scope = context.descriptionBox()?.allConceptualEntitySingletonInstanceScope
				else if (reference == DescriptionsPackage.eINSTANCE.singletonInstanceScalarDataPropertyValue_ScalarDataProperty)
					scope = context.descriptionBox()?.allEntityScalarDataPropertiesScope
					
			SingletonInstanceStructuredDataPropertyValue:
				if (reference == DescriptionsPackage.eINSTANCE.singletonInstanceStructuredDataPropertyValue_SingletonInstance)
					scope = context.descriptionBox()?.allConceptualEntitySingletonInstanceScope
				else if (reference == DescriptionsPackage.eINSTANCE.singletonInstanceStructuredDataPropertyContext_StructuredDataProperty)
					scope = context.descriptionBox()?.allEntityStructuredDataPropertiesScope
					
			StructuredDataPropertyTuple:
				if (reference == DescriptionsPackage.eINSTANCE.singletonInstanceStructuredDataPropertyContext_StructuredDataProperty)
					scope = context.descriptionBox()?.allStructuredDataPropertiesScope
			
			ScalarDataPropertyValue:
				if (reference == DescriptionsPackage.eINSTANCE.scalarDataPropertyValue_ScalarDataProperty)
					scope = context.descriptionBox()?.allScalarDataPropertiesScope
			
			ConceptInstance:
				if (reference == DescriptionsPackage.eINSTANCE.conceptInstance_SingletonConceptClassifier)
					scope = context.descriptionBox()?.allConceptsScope		
					
			ReifiedRelationshipInstance:
				if (reference == DescriptionsPackage.eINSTANCE.reifiedRelationshipInstance_SingletonReifiedRelationshipClassifier)
					scope = context.descriptionBox()?.allReifiedRelationshipScope
					
			ReifiedRelationshipInstanceDomain:
				if (reference == DescriptionsPackage.eINSTANCE.reifiedRelationshipInstanceDomain_ReifiedRelationshipInstance)
					scope = context.descriptionBox()?.allReifiedRelationshipInstancesScope
				else if (reference == DescriptionsPackage.eINSTANCE.reifiedRelationshipInstanceDomain_Domain)
					scope = context.descriptionBox()?.allConceptualEntitySingletonInstanceScope
					
			ReifiedRelationshipInstanceRange:
				if (reference == DescriptionsPackage.eINSTANCE.reifiedRelationshipInstanceRange_ReifiedRelationshipInstance)
					scope = context.descriptionBox()?.allReifiedRelationshipInstancesScope
				else if (reference == DescriptionsPackage.eINSTANCE.reifiedRelationshipInstanceRange_Range)
					scope = context.descriptionBox()?.allConceptualEntitySingletonInstanceScope
					
			UnreifiedRelationshipInstanceTuple:
				if (reference == DescriptionsPackage.eINSTANCE.unreifiedRelationshipInstanceTuple_UnreifiedRelationship)
					scope = context.descriptionBox()?.allUnreifiedRelationshipScope
				else if (reference == DescriptionsPackage.eINSTANCE.unreifiedRelationshipInstanceTuple_Domain)
					scope = context.descriptionBox()?.allConceptualEntitySingletonInstanceScope
				else if (reference == DescriptionsPackage.eINSTANCE.unreifiedRelationshipInstanceTuple_Range)
					scope = context.descriptionBox()?.allConceptualEntitySingletonInstanceScope
					
		} 
		if (null !== scope)
			scope
		else
			super.getScope(context, reference)
	}
	
	
}