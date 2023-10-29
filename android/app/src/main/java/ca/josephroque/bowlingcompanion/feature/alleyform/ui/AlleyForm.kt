package ca.josephroque.bowlingcompanion.feature.alleyform.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import ca.josephroque.bowlingcompanion.R
import ca.josephroque.bowlingcompanion.core.designsystem.R as RCoreDesign
import ca.josephroque.bowlingcompanion.core.designsystem.components.form.FormRadioGroup
import ca.josephroque.bowlingcompanion.core.designsystem.components.form.FormSection
import ca.josephroque.bowlingcompanion.core.designsystem.components.list.ListSectionFooter
import ca.josephroque.bowlingcompanion.core.model.AlleyMaterial
import ca.josephroque.bowlingcompanion.core.model.AlleyMechanism
import ca.josephroque.bowlingcompanion.core.model.AlleyPinBase
import ca.josephroque.bowlingcompanion.core.model.AlleyPinFall
import ca.josephroque.bowlingcompanion.core.designsystem.text.quantityStringResource

@Composable
internal fun AlleyForm(
	name: String,
	nameErrorId: Int?,
	onNameChanged: (String) -> Unit,
	numberOfLanes: Int,
	onManageLanes: () -> Unit,
	material: AlleyMaterial?,
	onMaterialChanged: (AlleyMaterial?) -> Unit,
	pinFall: AlleyPinFall?,
	onPinFallChanged: (AlleyPinFall?) -> Unit,
	mechanism: AlleyMechanism?,
	onMechanismChanged: (AlleyMechanism?) -> Unit,
	pinBase: AlleyPinBase?,
	onPinBaseChanged: (AlleyPinBase?) -> Unit,
	modifier: Modifier = Modifier,
) {
	Column(
		modifier = modifier
			.verticalScroll(rememberScrollState())
			.fillMaxSize(),
	) {
		FormSection(titleResourceId = R.string.alley_form_details_title) {
			AlleyNameField(name = name, onNameChanged = onNameChanged, errorId = nameErrorId)

			Row(
				horizontalArrangement = Arrangement.spacedBy(8.dp),
				verticalAlignment = Alignment.CenterVertically,
				modifier = Modifier
					.fillMaxWidth()
					.clickable(onClick = onManageLanes)
					.padding(horizontal = 16.dp, vertical = 16.dp),
			) {
				Text(
					text = stringResource(R.string.alley_form_manage_lanes),
					style = MaterialTheme.typography.titleMedium,
					modifier = Modifier.weight(1f),
				)

				Text(
					text = quantityStringResource(R.plurals.alley_form_property_lanes_created, quantity = numberOfLanes, numberOfLanes),
					style = MaterialTheme.typography.bodyMedium,
					color = MaterialTheme.colorScheme.onSurfaceVariant,
				)

				Icon(
					painter = painterResource(RCoreDesign.drawable.ic_chevron_right),
					contentDescription = null,
					tint = MaterialTheme.colorScheme.onSurfaceVariant,
				)
			}
		}

		Divider()
		FormSection(modifier = Modifier.padding(top = 16.dp)) {
			MaterialPicker(material, onMaterialChanged)
		}

		Divider()
		FormSection(modifier = Modifier.padding(top = 16.dp)) {
			MechanismPicker(mechanism, onMechanismChanged)
		}

		Divider()
		FormSection(modifier = Modifier.padding(top = 16.dp)) {
			PinFallPicker(pinFall, onPinFallChanged)
		}

		Divider()
		FormSection(modifier = Modifier.padding(top = 16.dp)) {
			PinBasePicker(pinBase, onPinBaseChanged)
		}

		Divider()

		ListSectionFooter(footer = stringResource(R.string.alley_form_properties_help))
	}
}

@Composable
private fun AlleyNameField(name: String, onNameChanged: ((String) -> Unit)?, errorId: Int?) {
	OutlinedTextField(
		value = name,
		onValueChange = onNameChanged ?: {},
		label = { Text(stringResource(R.string.league_form_property_name)) },
		singleLine = true,
		isError = errorId != null,
		supportingText = {
			errorId?.let {
				Text(
					text = stringResource(it),
					color = MaterialTheme.colorScheme.error,
					modifier = Modifier.fillMaxWidth(),
				)
			}
		},
		trailingIcon = {
			if (errorId != null) {
				Icon(
					Icons.Default.Warning,
					tint = MaterialTheme.colorScheme.error,
					contentDescription = null
				)
			}
		},
		modifier = Modifier
			.fillMaxWidth()
			.padding(horizontal = 16.dp)
	)
}

@Composable
private fun MaterialPicker(material: AlleyMaterial?, onMaterialChanged: (AlleyMaterial?) -> Unit) {
	FormRadioGroup(
		title = stringResource(R.string.alley_form_property_material),
		subtitle = stringResource(R.string.alley_form_property_material_footer),
		options = AlleyMaterial.values(),
		allowNullableSelection = true,
		selected = material,
		titleForOption = {
			when (it) {
				AlleyMaterial.WOOD -> stringResource(R.string.alley_property_material_wood)
				AlleyMaterial.SYNTHETIC -> stringResource(R.string.alley_property_material_synthetic)
				null -> stringResource(RCoreDesign.string.none)
			}
		},
		onOptionSelected = onMaterialChanged,
	)
}

@Composable
private fun MechanismPicker(mechanism: AlleyMechanism?, onMechanismChanged: (AlleyMechanism?) -> Unit) {
	FormRadioGroup(
		title = stringResource(R.string.alley_form_property_mechanism),
		subtitle = stringResource(R.string.alley_form_property_mechanism_footer),
		options = AlleyMechanism.values(),
		allowNullableSelection = true,
		selected = mechanism,
		titleForOption = {
			when (it) {
				AlleyMechanism.DEDICATED -> stringResource(R.string.alley_property_mechanism_dedicated)
				AlleyMechanism.INTERCHANGEABLE -> stringResource(R.string.alley_property_mechanism_interchangeable)
				null -> stringResource(RCoreDesign.string.none)
			}
		},
		onOptionSelected = onMechanismChanged,
	)
}

@Composable
private fun PinFallPicker(pinFall: AlleyPinFall?, onPinFallChanged: (AlleyPinFall?) -> Unit) {
	FormRadioGroup(
		title = stringResource(R.string.alley_form_property_pin_fall),
		subtitle = stringResource(R.string.alley_form_property_pin_fall_footer),
		options = AlleyPinFall.values(),
		allowNullableSelection = true,
		selected = pinFall,
		titleForOption = {
			when (it) {
				AlleyPinFall.FREE_FALL -> stringResource(R.string.alley_property_pin_fall_freefall)
				AlleyPinFall.STRINGS -> stringResource(R.string.alley_property_pin_fall_strings)
				null -> stringResource(RCoreDesign.string.none)
			}
		},
		onOptionSelected = onPinFallChanged,
	)
}

@Composable
private fun PinBasePicker(pinBase: AlleyPinBase?, onPinBaseChanged: (AlleyPinBase?) -> Unit) {
	FormRadioGroup(
		title = stringResource(R.string.alley_form_property_pin_base),
		subtitle = stringResource(R.string.alley_form_property_pin_base_footer),
		options = AlleyPinBase.values(),
		allowNullableSelection = true,
		selected = pinBase,
		titleForOption = {
			when (it) {
				AlleyPinBase.OTHER -> stringResource(R.string.alley_property_pin_base_other)
				AlleyPinBase.BLACK -> stringResource(R.string.alley_property_pin_base_black)
				AlleyPinBase.WHITE -> stringResource(R.string.alley_property_pin_base_white)
				null -> stringResource(RCoreDesign.string.none)
			}
		},
		onOptionSelected = onPinBaseChanged,
	)
}